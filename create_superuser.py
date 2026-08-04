import urllib.request
import ssl
import json

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

API_KEY = "ptr_JraPC33inVYyK/oBFfWT0Shwn6C5WfGCU/edEL5R7H4="
BASE = "https://31.97.68.37:9443/api/endpoints/3/docker"

req = urllib.request.Request(f"{BASE}/containers/json?all=1")
req.add_header("X-API-Key", API_KEY)
containers = json.loads(urllib.request.urlopen(req, context=ctx).read().decode())

backend_id = None
for c in containers:
    if "/coleah-crm-backend-1" in c["Names"] or "backend" in str(c["Names"]):
        if "backend" in str(c["Names"]):
            backend_id = c["Id"]
            break

cmd = """python3 manage.py shell -c "
from django.contrib.auth import get_user_model;
User = get_user_model();
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'Admin@123!');
    print('Superuser created: admin / Admin@123!');
else:
    u = User.objects.get(username='admin');
    u.set_password('Admin@123!');
    u.is_superuser = True;
    u.is_staff = True;
    u.save();
    print('Superuser password reset: admin / Admin@123!');
" """

exec_req = urllib.request.Request(f"{BASE}/containers/{backend_id}/exec", method="POST")
exec_req.add_header("X-API-Key", API_KEY)
exec_req.add_header("Content-Type", "application/json")
exec_payload = json.dumps({"AttachStdout": True, "AttachStderr": True, "Cmd": ["sh", "-c", cmd]})
exec_id = json.loads(urllib.request.urlopen(exec_req, data=exec_payload.encode(), context=ctx).read())["Id"]

start_req = urllib.request.Request(f"{BASE}/exec/{exec_id}/start", method="POST")
start_req.add_header("X-API-Key", API_KEY)
start_req.add_header("Content-Type", "application/json")
output = urllib.request.urlopen(start_req, data=b"{}", context=ctx).read()
print(output.decode("utf-8", errors="replace"))

