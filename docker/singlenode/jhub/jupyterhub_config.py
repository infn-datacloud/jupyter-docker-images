# =============================================================================
# jupyterhub_config.py  —  single-node JupyterHub 
#
# Features:
#   - secrets read via *_FILE convention (Docker secrets in /run/secrets)
#   - IAM authentication (GenericOAuthenticator) with group authorization
#   - group extraction from "groups" claim; optional WLCG compat (wlcg.groups)
#   - DockerSpawner: per-user container, started as root (NB_*), image + RAM selection form
#   - mounts: shared (ro) + shared/{username} (rw) + users/{username}->/private (rw)
#   - idle-culler always active
#   - optional CVMFS (privileged + bind /cvmfs only if WITH_CVMFS=true)
#   - optional GPU support
# =============================================================================
import os

import dockerspawner
from oauthenticator.generic import GenericOAuthenticator

# -----------------------------------------------------------------------------
# 0) Secrets importing: if _FILE exists, populate from its content.
# -----------------------------------------------------------------------------
def _hydrate_from_file(name):
    p = os.environ.get(name + "_FILE")
    if p and os.path.exists(p):
        with open(p) as fh:
            os.environ[name] = fh.read().strip()


for _s in (
    "IAM_CLIENT_SECRET",
    "JUPYTERHUB_CRYPT_KEY",
    "JUPYTERHUB_API_TOKEN",
    "JUPYTER_PROXY_TOKEN",
):
    _hydrate_from_file(_s)

c = get_config()  # noqa: F821

# -----------------------------------------------------------------------------
# 1) Service Environment Variables
# -----------------------------------------------------------------------------
IAM_URL = os.environ.get("OAUTH_ENDPOINT", "https://iam.cloud.infn.it/").rstrip("/") + "/"
OAUTH_CALLBACK_URL = os.environ["OAUTH_CALLBACK_URL"]
IAM_CLIENT_ID = os.environ["IAM_CLIENT_ID"]
IAM_CLIENT_SECRET = os.environ["IAM_CLIENT_SECRET"]

OAUTH_GROUPS = [g.strip() for g in os.environ.get("OAUTH_GROUPS", "").replace(",", " ").split() if g.strip()]
ADMIN_OAUTH_GROUPS = [g.strip() for g in os.environ.get("ADMIN_OAUTH_GROUPS", "").replace(",", " ").split() if g.strip()]
OAUTH_SUB = os.environ.get("OAUTH_SUB", "")

DNS_NAME = os.environ.get("DNS_NAME", "")
JUPYTER_IMAGE_LIST = [i.strip() for i in os.environ.get("JUPYTER_IMAGE_LIST", "").split(",") if i.strip()]
JUPYTER_RAM_LIST = [r.strip() for r in os.environ.get("JUPYTER_RAM_LIST", "1G,2G,4G").split(",") if r.strip()]
JUPYTER_CPU_LIST = [c_.strip() for c_ in os.environ.get("JUPYTER_CPU_LIST", "1,2,4").split(",") if c_.strip()]
WITH_GPU = os.environ.get("WITH_GPU", "false").lower() in ("1", "true", "yes", "y", "t")
WITH_CVMFS = os.environ.get("JUPYTER_WITH_CVMFS", "False").lower() in ("1", "true", "yes", "y", "t")
# Compat WLCG: Extract groups from the wlcg.groups claim (JWT) instead of "groups".
# Disabled by default: enable only if your IAM does not populate "groups" in the userinfo.
WLCG_GROUPS_COMPAT = os.environ.get("WLCG_GROUPS_COMPAT", "false").lower() in ("1", "true", "yes", "y", "t")
POST_START_CMD = os.environ.get("JUPYTER_POST_START_CMD", "")
DOCKER_NETWORK_NAME = os.environ.get("DOCKER_NETWORK_NAME", "jupyterhub")
IDLE_CULLER_TIMEOUT = os.environ.get("IDLE_CULLER_TIMEOUT", "3600")

NOTEBOOK_DIR = os.environ.get("DOCKER_NOTEBOOK_DIR") or "/jupyterlab-workspace"
NOTEBOOK_MOUNT_DIR = (os.environ.get("DOCKER_NOTEBOOK_MOUNT_DIR", "").rstrip("/") + "/jupyter-mounts").lstrip("/")
NOTEBOOK_MOUNT_DIR = "/" + NOTEBOOK_MOUNT_DIR
WITH_S3FUSE = os.environ.get("WITH_S3FUSE", "true").lower() in ("1", "true", "yes", "y", "t")

DEFAULT_JLAB_IMAGE = "harbor.cloud.infn.it/datacloud-templates/jlab-base:latest"


# -----------------------------------------------------------------------------
# 2) JupyterHub core
# -----------------------------------------------------------------------------
c.JupyterHub.hub_ip = "0.0.0.0"
c.JupyterHub.hub_connect_ip = "jupyterhub"   # nome del servizio sulla rete docker
c.JupyterHub.bind_url = "http://0.0.0.0:8088"
c.JupyterHub.hub_bind_url = "http://:8088"
c.JupyterHub.admin_access = True
c.JupyterHub.log_level = 30

c.JupyterHub.tornado_settings = {
    "max_body_size": 1048576000,
    "max_buffer_size": 1048576000,
}

# TLS/ingress routing is handled by the external configurable-http-proxy (:8888)
c.JupyterHub.cleanup_servers = False
c.ConfigurableHTTPProxy.should_start = False
c.ConfigurableHTTPProxy.auth_token = os.environ.get("JUPYTER_PROXY_TOKEN", "")
c.ConfigurableHTTPProxy.api_url = "http://http_proxy:8001"

# Persistent DB and cookie secret
c.JupyterHub.db_url = "sqlite:////srv/jupyterhub/db/jupyterhub.sqlite"
c.JupyterHub.cookie_secret_file = "/srv/jupyterhub/cookies/jupyterhub_cookie_secret"

# -----------------------------------------------------------------------------
# 3) IAM Authentication (GenericOAuthenticator)
#    By default, groups are received from the "groups" claim (claim_groups_key).
#    The WLCG compatibility is optional and can be enabled with 
#    WLCG_GROUPS_COMPAT=true. In that case we use modify_auth_state_hook to 
#    normalize the groups in auth_state, without overwriting authenticate() 
#    (which changes across oauthenticator versions).
# -----------------------------------------------------------------------------
SCOPES = ["openid", "profile", "email", "offline_access"]
if WLCG_GROUPS_COMPAT:
    SCOPES += ["wlcg", "wlcg.groups"]

def _modify_auth_state_hook(authenticator, auth_state):
    """ Normalize WLCG groups from the JWT access token in the 'groups' claim.
    Executed only if WLCG_GROUPS_COMPAT=true. Decodes the access token without
    verifying the signature (IAM already verified it at issuance) and copies
    wlcg.groups -> oauth_user["groups"], stripping the leading "/".
    """
    try:
        import jwt
        token = auth_state.get("access_token")
        decoded = jwt.decode(token, options={"verify_signature": False})
        wlcg = decoded.get("wlcg.groups")
        if wlcg:
            normalized = [g[1:] if g.startswith("/") else g for g in wlcg]
            user_info = auth_state.setdefault(
                authenticator.user_auth_state_key, {}
            )
            user_info["groups"] = normalized
    except Exception as e:  # prevent to block the login for a failed parsing
        authenticator.log.warning("WLCG groups compat hook failed: %s", e)
    return auth_state

c.JupyterHub.authenticator_class = "generic-oauth"

c.GenericOAuthenticator.client_id = IAM_CLIENT_ID
c.GenericOAuthenticator.client_secret = IAM_CLIENT_SECRET
c.GenericOAuthenticator.oauth_callback_url = OAUTH_CALLBACK_URL
c.GenericOAuthenticator.authorize_url = IAM_URL + "authorize"
c.GenericOAuthenticator.token_url = IAM_URL + "token"
c.GenericOAuthenticator.userdata_url = IAM_URL + "userinfo"
c.GenericOAuthenticator.scope = SCOPES
c.GenericOAuthenticator.username_claim = "preferred_username"
c.GenericOAuthenticator.claim_groups_key = "groups"
c.GenericOAuthenticator.allowed_groups = set(OAUTH_GROUPS)
c.GenericOAuthenticator.admin_groups = set(ADMIN_OAUTH_GROUPS)
c.GenericOAuthenticator.manage_groups = True
c.GenericOAuthenticator.enable_auth_state = True
# Only allow users who are in the allowed_groups: authorization is handled by allowed_groups
c.GenericOAuthenticator.allow_all = False

if WLCG_GROUPS_COMPAT:
    c.GenericOAuthenticator.modify_auth_state_hook = _modify_auth_state_hook

# Admins are managed through dedicated IAM group 
if OAUTH_SUB:
    c.Authenticator.admin_users = set()  

# -----------------------------------------------------------------------------
# 4) Spawner: DockerSpawner 
# -----------------------------------------------------------------------------
_default_image = JUPYTER_IMAGE_LIST[0] if JUPYTER_IMAGE_LIST else DEFAULT_JLAB_IMAGE
c.DockerSpawner.image = _default_image
# dockerspawner 13 rejects self.image from user_options if the image is not
# in allowed_images ("Specifying image to launch is not allowed").
# We populate the allowlist with the list of allowed images (or just the default)
c.DockerSpawner.allowed_images = JUPYTER_IMAGE_LIST or [_default_image]
c.DockerSpawner.network_name = DOCKER_NETWORK_NAME
c.DockerSpawner.use_internal_ip = True
c.DockerSpawner.remove = True
c.DockerSpawner.pull_policy = "always"
c.DockerSpawner.http_timeout = 600
c.DockerSpawner.debug = True

c.DockerSpawner.default_url = "/lab"
c.Spawner.default_url = "/lab"
c.DockerSpawner.cmd = ["jupyterhub-singleuser"]

# Start as root in the container.
c.DockerSpawner.cmd = ["jupyterhub-singleuser", "--allow-root"]
c.DockerSpawner.extra_create_kwargs = {"user": "0:0"}

c.DockerSpawner.environment = {
    "GRAFANA_EXTERNAL_URL": f"https://{DNS_NAME}/grafana" if DNS_NAME else "",
    "JUPYTER_ENABLE_LAB": "yes",
}

# Limiti di risorse di default (applicati SEMPRE, anche se lo spawn non passa
# dal form: re-spawn post-cull, avvii via API, ecc.). Il form può alzarli/
# abbassarli per-utente nel pre_spawn_hook.

# Default resource limits (applied ALWAYS, even if spawning does not go
# through the form: post-cull re-spawn, API launches, etc.). The form can
# increase/decrease them per-user in the pre_spawn_hook.

DEFAULT_MEM = os.environ.get("JUPYTER_DEFAULT_MEM", JUPYTER_RAM_LIST[0] if JUPYTER_RAM_LIST else "2G")
DEFAULT_CPU = float(os.environ.get("JUPYTER_DEFAULT_CPU", "1"))
c.DockerSpawner.mem_limit = DEFAULT_MEM
c.DockerSpawner.cpu_limit = DEFAULT_CPU

# User notebook persistence 
c.DockerSpawner.notebook_dir = NOTEBOOK_DIR
_volumes = {
    NOTEBOOK_MOUNT_DIR + "/shared": {
        "bind": NOTEBOOK_DIR + "/shared",
        "mode": "ro",
    },
    NOTEBOOK_MOUNT_DIR + "/shared/{username}": {
        "bind": NOTEBOOK_DIR + "/shared/{username}",
        "mode": "rw",
    },
    NOTEBOOK_MOUNT_DIR + "/users/{username}/": {
        "bind": NOTEBOOK_DIR + "/private",
        "mode": "rw",
    },
}
if WITH_CVMFS:
    _volumes["/cvmfs"] = {"bind": NOTEBOOK_DIR + "/cvmfs", "mode": "ro"}
c.DockerSpawner.volumes = _volumes

# Privilegi host: necessari solo per CVMFS (FUSE). Applicati a tutti gli spawn.
# if WITH_CVMFS:
#     c.DockerSpawner.extra_host_config = {
#         "cap_add": ["SYS_ADMIN"],
#         "privileged": True,
#     }

if WITH_S3FUSE: 
    c.DockerSpawner.extra_host_config = {
        "cap_add": ["SYS_ADMIN"],
        "devices": ["/dev/fuse:/dev/fuse:rwm"],
        "security_opt": ["apparmor=unconfined"],
    }

# GPU (disabled by default)
if WITH_GPU:
    _hc = dict(getattr(c.DockerSpawner, "extra_host_config", {}) or {})
    _hc["device_requests"] = [
        {"Driver": "nvidia", "Count": -1, "Capabilities": [["gpu"]]}
    ]
    c.DockerSpawner.extra_host_config = _hc

# optional post-start
if POST_START_CMD:
    c.DockerSpawner.post_start_cmd = POST_START_CMD

# -----------------------------------------------------------------------------
# 5) Spawn form: image selection + RAM (+ GPU if enabled)
# -----------------------------------------------------------------------------
_option_template = """
<label for="img">Select your desired image:</label>
<input list="images" name="img" value="{default_image}">
<datalist id="images">
{images}
</datalist>
<br>
<label for="mem">Select your desired memory size:</label>
<select name="mem" size="1">
{rams}
</select>
<br>
<label for="cpu">Select your desired CPU limit:</label>
<select name="cpu" size="1">
{cpus}
</select>
{gpu}
"""

def _options_form(spawner):
    image_options = "\n".join(
        f'<option value="{img}">{img.split("/")[-1]}</option>'
        for img in JUPYTER_IMAGE_LIST
    )
    ram_options = "\n".join(
        f'<option value="{ram}">{ram}B</option>' for ram in JUPYTER_RAM_LIST
    )
    cpu_options = "\n".join(
        f'<option value="{cpu}">{cpu} CPU</option>' for cpu in JUPYTER_CPU_LIST
    )
    if WITH_GPU:
        gpu_options = """
        <br>
        <label for="gpu">GPU:</label>
        <select name="gpu" size="1">
        <option value="Y">Yes</option>\n<option value="N">No</option>
        </select>
        """
    else:
        gpu_options = '<input type="hidden" name="gpu" value="N">\n'
    return _option_template.format(
        default_image=_default_image,
        images=image_options,
        rams=ram_options,
        cpus=cpu_options,
        gpu=gpu_options,
    )


class CustomDockerSpawner(dockerspawner.DockerSpawner):
    """Subclass used to process the spawn form.
    """

    def options_from_form(self, formdata):
        opts = {
            "image": "".join(formdata.get("img", [])).strip() or _default_image,
            "mem_limit": "".join(formdata.get("mem", [])).strip() or DEFAULT_MEM,
            "cpu_limit": "".join(formdata.get("cpu", [])).strip() or str(DEFAULT_CPU),
            "use_gpu": "".join(formdata.get("gpu", [])).strip() == "Y",
        }
        self.log.info("SPAWN options_from_form -> %s", opts)
        return opts

c.JupyterHub.spawner_class = CustomDockerSpawner
c.Spawner.options_form = _options_form

async def _pre_spawn_hook(spawner):
    """
    Apply the form choices and inject the IAM tokens into the user container.
    The tokens (access/refresh) are needed within jlab-base for oidc-agent/rclone.
    """
    
    opts = spawner.user_options or {}
    spawner.mem_limit = opts.get("mem_limit") or DEFAULT_MEM
    try:
        spawner.cpu_limit = float(opts.get("cpu_limit") or DEFAULT_CPU)
    except (TypeError, ValueError):
        spawner.cpu_limit = DEFAULT_CPU
    if WITH_GPU and opts.get("use_gpu"):
        hc = dict(spawner.extra_host_config or {})
        hc["device_requests"] = [
            {"Driver": "nvidia", "Count": -1, "Capabilities": [["gpu"]]}
        ]
        spawner.extra_host_config = hc

    # --- IAM token injection in the single-user environment ---
    auth_state = await spawner.user.get_auth_state()
    if not auth_state:
        spawner.log.warning("Nessun auth_state per %s: token non iniettati "
                            "(enable_auth_state e CRYPT_KEY impostati?)",
                            spawner.user.name)
        return
    env = spawner.environment
    env["IAM_SERVER"] = IAM_URL.rstrip("/")
    env["IAM_CLIENT_ID"] = IAM_CLIENT_ID
    env["IAM_CLIENT_SECRET"] = IAM_CLIENT_SECRET
    env["ACCESS_TOKEN"] = auth_state.get("access_token", "")
    env["REFRESH_TOKEN"] = auth_state.get("refresh_token", "")
    env["USERNAME"] = spawner.user.name
    env["JUPYTERHUB_ACTIVITY_INTERVAL"] = "15"
    user_info = auth_state.get(
        getattr(c.GenericOAuthenticator, "user_auth_state_key", "oauth_user"), {}
    )
    groups = user_info.get("groups") if isinstance(user_info, dict) else None
    if groups:
        env["GROUPS"] = " ".join(groups)


c.Spawner.pre_spawn_hook = _pre_spawn_hook

# -----------------------------------------------------------------------------
# 6) Idle culler (releases resources from inactive sessions)
# -----------------------------------------------------------------------------
c.JupyterHub.load_roles = [
    {
        "name": "idle-culler",
        "scopes": [
            "list:users",
            "read:users:activity",
            "read:servers",
            "delete:servers",
        ],
        "services": ["idle-culler"],
    }
]

c.JupyterHub.services = [
    {
        "name": "idle-culler",
        "command": [
            "python3", "-m", "jupyterhub_idle_culler",
            f"--timeout={IDLE_CULLER_TIMEOUT}",
        ],
    }
]