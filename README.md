<!-- vscode-markdown-toc -->
* 1. [Poboy's Conda Package Server](#PoboysCondaPackageServer)
* 2. [Docker Build instructions](#DockerBuildinstructions)
* 3. [Environment Variables](#EnvironmentVariables)
* 4. [H2O implementation details](#H2Oimplementationdetails)
* 5. [Maintenance Activities](#MaintenanceActivities)
	* 5.1. [Refreshing Poboy's Container Image](#RefreshingPoboysContainerImage)
	* 5.2. [Cleaning up persistent storage](#Cleaninguppersistentstorage)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='PoboysCondaPackageServer'></a>Poboy's Conda Package Server

This is a server that acts as a repository for conda packages.  It is a "poor-man's" replacement for Anaconda Server.  Only small groups behind a firewall should feel comfortable using this. There is no authentication, nor logging.  Anybody can upload and delete packages!

##  2. <a name='DockerBuildinstructions'></a>Docker Build instructions

The script ``refresh_poboy_server.sh`` can be used to quickly setup the server. It builds two docker images

1. poboys_base_image - as base image with all dependencies required for poboy's server to run
2. poboys_conda_package_server - the docker image with the poboy's server code. It is built on top of the base image.

To build both docker images (needed for the first time) and start the server issue the command

```bash
mkdir conda-repo-root && \
git clone https://github.com/h2oai/poboys_conda_package_server.git && \
cd poboys_conda_package_server && ./refresh_poboy_server.sh --refreshbase
```

It has a simple web interface - browse to http://localhost:6969 to view the interface. 

##  3. <a name='EnvironmentVariables'></a>Environment Variables

Poboy's uses environment variables for configuration. To specify a different port or an S3 bucket, setup the appropriate environment variables listed below, and then run ``refresh_poboy_server.sh`` to refresh only the poboy server image

```bash
export POBOYS_PORT=6969
export POBOYS_S3_BUCKET=<YOURBUCKET>
export AWS_ACCESS_KEY_ID=<YOURKEY>
export AWS_SECRET_ACCESS_KEY=<YOURSECRET>
```

Packages available in Poboy's server can be released to anaconda cloud at the click of a button, but it requires one to configure the following environment variables. If ANACONDA_ORG is set then by default packages will be uploaded to the Organization. If not set, then packages are uploaded to user's account.

```bash
export ANACONDA_USERNAME=<YOURANACONDAUSERNAME>
export ANACONDA_PASSWORD=<YOURPASSWORD>
export ANACONDA_ORG=<YOURORG>
```

##  4. <a name='H2Oimplementationdetails'></a>H2O implementation details

* At H2O we have implemented the Poboy's Anaconda Server as a stack in Rancher. The stack contains one container and a persistent storage provided by Rancher. 
* The Poboy docker image built above is available in the docker registry with the tag `docker.h2o.ai/poboys_conda_package_server6969`. It is used to instantiate the container in Rancher. 
* The persistent storage volume is mounted in this container. 
* Conda packages created as part of Jenkins build process are uploaded to Poboy's from where they can be installed in verified, after which can be released to Anaconda cloud.

##  5. <a name='MaintenanceActivities'></a>Maintenance Activities

Over time following maintenance activities would need to be performed

###  5.1. <a name='RefreshingPoboysContainerImage'></a>Refreshing Poboy's Container Image

In case there is need to enhance capability in Poboy's we would need to refresh the container image in internal docker hub as well as in Poboys. Mostly we will not need to update the base container image. Below steps shoe updating the poboy server container image. To also update the base image use the `--refreshbase` option to `refresh_poboys_server.sh`.

* Ensure latest code is pushed to master. To build poboy's image from the latest  master DO NOT use `--localsource` option. It is useful mainly for local development cycle.
* `./refresh_poboy_server.sh` without any options will recreate the poboys_conda_package_server docker image
* Tag the latest image for dployment to docker.h2o.ai repo `docker tag poboys_conda_package_server:latest docker.h2o.ai/poboys_conda_package_server:latest`
* If needed login to the internal docker repo `docker login docker.h2o.ai` with user `h2oai` (ask Anmol for password) and then push the image `docker push docker.h2o.ai/poboys_conda_package_server:latest`
* In rancher search for poboy's stack and perform an `Upgrade`. This will cause the existing container to stop and a new container to be deployed with the latest docker image.

NOTE : Ensure the base image is updated periodically to use the latest conda and anaconda-client versions..or else we get weird issues !!!!! 

###  5.2. <a name='Cleaninguppersistentstorage'></a>Cleaning up persistent storage

The Release build pipeline in jenkins is configured to upload the conda build artifacts to Poboy's for each run. Over time there are a large number of build artifacts generated which impact the overall indexing performance of Poboy's, so it is important to keep housekeeping periodically.

- Currently the artifacts are being generated in `linux-64` and `noarch` sub-directories in the `pkgs` channel.
- In each of these directories a file `keepfiles.txt` is used to keep the list of files that should not be deleted. Periodically update this file to only include the files that need to be preserved.
- Once the file is updated run `cleanup.sh`. This will remove all the files that are not mentioned in `keepfiles.txt`




License
=======

All files are licensed under the BSD 3-Clause License as follows:
 
| Copyright (c) 2015, Activision Publishing, Inc.  
| All rights reserved.
| 
| Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
| 
| 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
|  
| 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
|  
| 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
|  
| THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

