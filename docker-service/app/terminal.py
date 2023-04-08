import subprocess

class Terminal:
    def run_command(self, command: str) -> str:
        try:
            output = subprocess.check_output(command, stderr=subprocess.STDOUT, shell=True, text=True)
            return output
        except subprocess.CalledProcessError as e:
            return e.output

