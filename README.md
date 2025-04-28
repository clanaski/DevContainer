# Dev Containers

## What is it?

A **devcontainer** (short for *development container*) is a pre-configured environment for coding. It includes everything you need—like tools, libraries, and settings—so your code runs the same way on any machine.

Think of it like a ready-to-use coding workspace packed into a container. It helps developers avoid the "it works on my machine" problem.

## Use for WellFit

WellFit has a variety of APIs and pipelines that rely on different versions of essential tools, such as NuGet. This version mismatch can—and has—led to errors during pipeline execution and caused friction between teams. By using DevContainers, we can standardize the development environment, ensuring that only the specified versions of tools are available and used consistently across the board.

Beyond version control, DevContainers also simplifies the developer experience by providing immediate access to all necessary tools and repositories. There's no need to manually clone repos or install multiple VS Code extensions—everything is pre-configured and ready to go.

## Tools in the Dev Container

All tools/features installed onto the container are listed under the "Features" block within .devcontainer. This is also where the versions and other options can be configured as well. If no version is declared, then the latest version from the [GitHub Repository](https://github.com/devcontainers/features) of that tool is used.

| Tool  | Version | Use |
| ------------- | ------------- | ------------- |
| DevContainer Common Utils  | Latest  | |
| Azure CLI  | Latest  | Installs the Azure CLI along with needed dependencies. |
| Node | lts  | Installs Node.js, nvm, yarn, pnpm, and needed dependencies |
| Powershell  | Installs PowerShell along with needed dependencies. | |
| Terraform  | Latest  | |
| Java  | Latest  | |
| Git  | Latest  | |
| Dotnet  | lts  | |
| Python | Latest  | |
| Docker-in-Docker  | Latest  | |
| Git  | Latest  | |
| GitHub-CLI | lts  | |

## File Structure

### Docker File

Used as the base file to pull the image needed to build the container, pulls in the repos into the container. (runs the startup script? - move to devcontainer.json when finished)

### devcontainer.json

Holds the features or tool configurations within the container. It also holds the VSCode extension that will be installed within the Container.

### startup.sh

Startup script to authenticate to devops and install any features not currently available within the [GitHub Repository](https://github.com/devcontainers/features)

### Requirements

1) Portal and Azure DevOps access
2) Docker Desktop
3) WSL
4) VSCode
5) Dev Containers extension within VSCode

## Using the DevContainer

The DevContainer configuration is located at the root of the repository in the `.devcontainer` folder.

### Steps to Build and Launch the DevContainer

1. **Open the repository in Visual Studio Code.**
2. **Ensure Docker Desktop is running.**
3. In the bottom-left corner of VSCode, click the **green tab** (>< icon) to open the command menu.
4. Select **"Open in Dev Container"**.

### What to Expect

- VSCode will begin building and initializing the DevContainer.
- A status box will appear in the **bottom-right corner**, showing build progress.
- Click the box to view real-time logs and see what is being built.

Once the initial image is built:

- VSCode will automatically open in the DevContainer.
- Additional tools and features will continue to install.
- The build logs remain accessible via the status box in the lower-right corner.

> ⚠️ **Note:** The first-time setup can take **10–15 minutes**, depending on the number of tools and features in the container.

### After the Build

- A list of installed extensions will be visible in VSCode.
- The terminal will default

### Useful Links

- [DevContainers for Azure and .NET](https://dev.to/azure/devcontainers-for-azure-and-net-5942)

- [GitHub Feature Repository](https://github.com/devcontainers/features)
