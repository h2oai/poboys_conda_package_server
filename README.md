==============================
 Poboy's Conda Package Server
==============================

This is a server that acts as a repository for conda packages.  It is a "poor-man's" replacement
for Anaconda Server.  Only small groups behind a firewall should feel comfortable using this.
There is no authentication, nor logging.  Anybody can upload and delete packages!

Docker instructions
===================

The script ``refresh_poboy_server.sh`` can be used to quickly setup the server. It builds two docker images

1. poboys_base_image - as base image with all dependencies required for poboy's server to run
2. poboys_conda_package_server - the docker image with the poboy's server code. It is built on top of the base image.

To build both docker images (needed for the first time) and start the server issue the command

``mkdir conda-repo-root && \
  git clone https://github.com/h2oai/poboys_conda_package_server.git && \
  cd poboys_conda_package_server && ./refresh_poboy_server.sh --refreshbase``

It has a simple web interface - browse to the appropriate url and have a look::

    http://your.hostname:6969

Environment Variables
=====================

If you want to specify a different port or an S3 bucket then you can setup the following environment variables on the
Host machine and run ``refresh_poboy_server.sh`` to refresh only the poboy server image

    export POBOYS_PORT=6969
    export POBOYS_S3_BUCKET=<YOURBUCKET>
    export AWS_ACCESS_KEY_ID=<YOURKEY>
    export AWS_SECRET_ACCESS_KEY=<YOURSECRET>

Packages available in Poboy's server can we uploaded to anaconda cloud at the click of a button. Ensure the following
environment variables are set

    export ANACONDA_USERNAME=<YOURANACONDAUSERNAME>
    export ANACONDA_PASSWORD=<YOURPASSWORD>
    export ANACONDA_ORG=<YOURORG>

Note: if ANACONDA_ORG is set then by default packages will be uploaded to the Organization. If not set, then packages are
uploaded to user's account.


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

