## Docker Quickstart
1. Clone the repository

2. Change directory to the root of the repo
    ```bash
    cd lakepodos-build
    ```

3. Build a docker image:
    ```bash
    docker build -t unilake/lakepod-os:v1 .
    ```

4. Run in a Docker container:
    ```bash
    docker run --rm -it --privileged \
    -v $(pwd):/lakepod-os \
    -w /lakepod-os \
    unilake/lakepod-os:v1
    ```

5. Build the ISO image
    ```bash
    ./build.sh
    ```