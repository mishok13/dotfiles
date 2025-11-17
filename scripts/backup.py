# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "typer",
# ]
# ///

import subprocess
import typer
from pathlib import Path
from datetime import datetime
from typing import Annotated


def main(
    db: Annotated[str, typer.Argument()],
    services: Annotated[list[str], typer.Argument(default_factory=list)],
    user: Annotated[str | None, typer.Option("--user", "-U")] = None,
    dbname: Annotated[str | None, typer.Option("--dbname", "-D")] = None,
    backup_dir: Annotated[
        Path,
        typer.Option(
            dir_okay=True,
            file_okay=False,
            writable=True,
            exists=True,
            resolve_path=True,
        ),
    ] = Path("/mnt/share/backups/databases/"),
) -> None:
    for service in services:
        subprocess.run(["docker", "stop", service], capture_output=True, check=True)
    try:
        dump_command = ["pg_dump"]
        if user is not None:
            dump_command.extend(["-U", user])
        if dbname is not None:
            dump_command.extend([dbname])
        command = [
            "docker",
            "exec",
            db,
            "/bin/sh",
            "-c",
            " ".join(dump_command),
        ]
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True,
        )
        filename = backup_dir / f"{db}-{datetime.now():%Y%m%dT%H%M%S}.sql"
        with open(filename, "w") as f:
            f.write(result.stdout)
    finally:
        for service in services:
            subprocess.run(
                ["docker", "start", service], capture_output=True, check=True
            )


if __name__ == "__main__":
    typer.run(main)
