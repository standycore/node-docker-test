# Dockerfiles are used to build images
# to build, use  docker build --tag node-docker .
# if no tag is used, then it defaults to "latest"

# derive image from an existing image, its easier
# FROM node:18
FROM oven/bun

WORKDIR /app

# copy package.json (first arg) to workdir/package.json (second arg)
# since workdir is /app, it will be ./package.json, so we don't need to put app/
COPY package.json package.json
# NOTE: the ADD command is similar to COPY, but can do more. COPY simply copies from src to dst
# ADD can use a url as a source, and if the src is a recognized compressed format (such as gzip), then it will be unpacked in the dst
# however, best practice is to use COPY if you dont need the extra features of ADD

# installs all modules once the package.json is copied
# if u want to ignore dev dependencies such as eslint or so, use the --omit=dev arg (npm) or --production arg (npm or bun)
# RUN npm install --omit=dev
RUN bun install --production

# copy source code (everything in the current dir) to workdir (/app)
COPY . .

# exposes port 8080, or whichever port is used for the server
# but ONLY exposes it for anything running inside the container that is run
# so if you tried to access a server from outside such as in a browser, it would not work
# to be able to access from outside the container, you need a --publish or -p argument ex:
# docker run --publish 8080:8080 node-docker
# publish maps the outside port to the inner port. <outside>:<inside>
# this means it can be another port such as 3000:8080, and so you will have to connect to it via port 3000 outside
# NOTE: if you use publish without EXPOSE, it will expose whatever is used in publish as a default, and can be accessed from within and outside
# https://stackoverflow.com/questions/22111060/what-is-the-difference-between-expose-and-publish-in-docker
EXPOSE 8080

# arguments used in the entrypoint. kind of confusing still
# my question is what is the default entrypoint then
# https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile

# when you run dockerfile with  docker run <container> <args>, CMD fills in the args if none are specified, essentially default args
# so if CMD is [ "bun", "index.js" ], then the equivalent command would be  docker run <container> bun index.js
# but if args are specified in the command, then the CMD args are overwritten. for example:
# docker run <container> node server.js   has arguments already in the command, so the CMD args in the dockerfile will not be used
# MAYBE!!!!!! im not 100% sure  
CMD [ "bun", "index.js" ]

# NOTE: using CTRL+C will not stop the docker container if run attached to the terminal
# so it might be better to start it detached with --detach or -d argument:

# NOTE: when running a container, a name is automatically assigned to it thats unique, such as cool_dubinsky, which might be inconvenient
# to use your own name, use the --name <name> arg

# final example container run command:
# docker run --detach --publish <outside-port>:<inside-port> --name <container-name> <image-name>
# docker run --detach --publish 8080:8080 --name bun-docker bun-docker-test

# to stop running container:  docker stop <container-name>
# NOTE: this does not remove it from the containers, only stops it. so if you try to re-run with the same name, it will say its still there
# to remove a container (after stopping):  docker rm <container-name>

# to see the running containers:  docker container ls

# to enter a docker container (similar to SSH into a machine):  docker exec -it <container-name> bash
# this creates a bash terminal for use and uses the terminal u used as the proxy, like SSH
# -it stands for --interactive and --tty args. im not sure what they do really yet
# https://stackoverflow.com/questions/59965032/docker-run-with-interactive-and-tty-flag