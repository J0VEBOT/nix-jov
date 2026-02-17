start_all()

machine.wait_until_succeeds(
    "systemctl show -p Result home-manager-alice.service | grep -q 'Result=success'"
)

machine.wait_until_succeeds("test -f /home/alice/.groc/groc.json")

uid = machine.succeed("id -u alice").strip()
machine.succeed("loginctl enable-linger alice")
machine.succeed(f"systemctl start user@{uid}.service")
machine.wait_for_unit(f"user@{uid}.service")

machine.wait_until_succeeds("test -S /run/user/1000/bus")

machine.succeed("mkdir -p /tmp/groc")
machine.succeed("chmod 1777 /tmp/groc")

user_env = "XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
machine.succeed(f"su - alice -c '{user_env} systemctl --user daemon-reload'")
machine.succeed(f"su - alice -c '{user_env} systemctl --user start groc-gateway.service'")
machine.wait_for_unit("groc-gateway.service", user="alice")

try:
    machine.wait_for_open_port(18999)
except Exception:
    machine.succeed(
        f"su - alice -c '{user_env} systemctl --user status groc-gateway.service --no-pager -n 200 > /tmp/groc/systemctl-status.txt 2>&1' || true"
    )
    machine.succeed(
        f"su - alice -c '{user_env} journalctl --user -u groc-gateway.service --no-pager -n 200 -o cat > /tmp/groc/journalctl.txt 2>&1' || true"
    )
    machine.succeed("coredumpctl info --no-pager | tail -n 200 >&2 || true")
    machine.succeed("ls -la /tmp/groc 1>&2 || true")
    machine.succeed("ls -la /tmp/groc/node-report* 1>&2 || true")
    machine.succeed(
        f"su - alice -c '{user_env} systemctl --user show groc-gateway.service --no-pager -p Environment > /tmp/groc/systemctl-env.txt 2>&1' || true"
    )
    machine.succeed("sed -n '1,200p' /tmp/groc/systemctl-env.txt >&2 || true")
    machine.succeed("wc -c /tmp/groc/systemctl-env.txt >&2 || true")
    machine.succeed(
        f"su - alice -c '{user_env} systemctl --user cat groc-gateway.service --no-pager > /tmp/groc/systemctl-unit.txt 2>&1' || true"
    )
    machine.succeed("sed -n '1,200p' /tmp/groc/systemctl-unit.txt >&2 || true")
    machine.succeed("wc -c /tmp/groc/systemctl-unit.txt >&2 || true")
    machine.succeed("tail -n 40 /tmp/groc/systemctl-status.txt >&2 || true")
    machine.succeed("tail -n 40 /tmp/groc/journalctl.txt >&2 || true")
    raise
