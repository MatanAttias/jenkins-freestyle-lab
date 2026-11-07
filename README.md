# Jenkins Freestyle Project – Node.js & Docker

A hands-on DevOps lab that uses **Jenkins Freestyle Project** to fetch a simple Node.js application from GitHub, build a Docker image, and run the application in a container.

## What this project demonstrates

1. Jenkins checks out the `main` branch from GitHub.
2. Jenkins runs a shell step to build a Docker image.
3. Jenkins runs a second shell step to start a Docker container.
4. The application becomes accessible on port `8081` of the Ubuntu host.
5. Build logs and errors can be inspected through **Console Output**.

```text
GitHub (main)
    |
    v
Jenkins Freestyle Job
    |-- Git checkout
    |-- docker build -t node-app .
    `-- docker run -d --name node-todo-app -p 8081:8080 node-app:latest
                                                   |
                                                   v
                                       http://localhost:8081
                                       (inside the Ubuntu VM)
```

## Project files

```text
jenkins-freestyle-lab/
├── app.js
├── package.json
├── Dockerfile
└── README.md
```

- **`app.js`** – HTTP server using Node.js's built-in `http` module. It returns `Hello from Jenkins and Docker!`.
- **`package.json`** – Node.js project metadata and start script.
- **`Dockerfile`** – Instructions for packaging and starting the application in Docker.

## Requirements

- Ubuntu VM with Jenkins installed and running
- Git and Docker installed in the Ubuntu VM
- Jenkins Git plugin / Freestyle job support
- Access to the public GitHub repository
- Docker permission for the Jenkins service account (see security note below)

The application listens on **port 8080 inside the container**. Jenkins itself also uses port `8080` on the Ubuntu host, so the container is published through host port **8081**.

## Jenkins configuration

Create a **Freestyle project** and configure:

| Setting | Value |
| --- | --- |
| GitHub project URL | `https://github.com/MatanAttias/jenkins-freestyle-lab` |
| Source Code Management | `Git` |
| Repository URL | `https://github.com/MatanAttias/jenkins-freestyle-lab.git` |
| Branches to build | `*/main` |

Add two **Build Steps → Execute shell** steps, in this order.

**Build step 1 – Build image**

```bash
docker build -t node-app .
```

**Build step 2 – Run container**

```bash
docker run -d --name node-todo-app -p 8081:8080 node-app:latest
```

Save the job, choose **Build Now**, and inspect **Console Output**.

## Verify the result

Run on the Ubuntu VM:

```bash
docker ps
```

The running container should be named `node-todo-app`, use `node-app:latest`, and publish `8081->8080/tcp`.

Open this address **from a browser inside the Ubuntu VM**:

```text
http://localhost:8081
```

Expected page heading:

```text
Hello from Jenkins and Docker!
```

> If opening the site from Windows instead of inside Ubuntu, additional VM network configuration may be needed. `localhost` always refers to the machine where the browser is running.

## Issues resolved during the lab

| Issue | Cause | Resolution |
| --- | --- | --- |
| Jenkins failed to start | Java was missing | Installed OpenJDK 21 and restarted Jenkins |
| Jenkins could not use Docker | The `jenkins` service account lacked Docker socket access | Added `jenkins` to the `docker` group and restarted Jenkins |
| `docker ps` failed for the Ubuntu user | The interactive user lacked Docker socket access | Added that user to the `docker` group and refreshed group membership |
| Jenkins could not build the application initially | The Dockerfile was empty | Created a Dockerfile for the Node.js application |
| Local Node.js test failed | Invalid `package.json` | Fixed the package configuration |
| Windows local test could not bind port `8080` | Windows denied the bind operation | Temporarily tested on port `3000`, then restored container configuration to `8080` |
| Git branch mismatch | Local `master` did not match Jenkins `main` configuration | Aligned the project with the `main` branch |

## Running the job again

The lab's original second build step uses a fixed container name. **If `node-todo-app` already exists, a repeated build will fail** with a name conflict.

For a manual rerun, remove the existing container **on the Ubuntu VM** before clicking **Build Now**:

```bash
docker rm -f node-todo-app
```

The image remains available and is rebuilt by Jenkins. A future improvement would be to handle replacement safely inside the job, but that is **not** part of the original exercise.

## Security and scope

- Membership in the `docker` group effectively grants powerful host-level privileges. This setup is appropriate for a controlled local learning lab, not a production security model.
- The Freestyle job is triggered **manually** with **Build Now**. This exercise does **not** configure a GitHub webhook or automatic builds on each push.
- This is a learning example, not a production deployment pipeline.

## Main takeaway

**GitHub stores the source code; Jenkins orchestrates the steps; Docker packages and runs the application.**
