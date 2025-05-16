import subprocess

# Define the prompt as input to be passed to the command
prompt = "Describe this image: R6_L0002.jpg"

try:
    # Use subprocess to pass input to the command via stdin
    result = subprocess.run(
        ["ollama", "run", "lrc"],
        input=prompt,
        capture_output=True,
        text=True,
        check=True
    )

    # Check if the output exists
    if result.stdout:
        print("Output:\n", result.stdout)
    else:
        print("No output from the command.")

except subprocess.CalledProcessError as e:
    print(f"Command failed with return code {e.returncode}")
    print("Error output:\n", e.stderr)

except FileNotFoundError:
    print("Ollama is not installed or not found in PATH. Ensure it's installed and accessible.")