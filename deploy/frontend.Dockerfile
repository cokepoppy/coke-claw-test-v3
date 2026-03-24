FROM node:20-alpine AS build
WORKDIR /workspace
COPY . .
WORKDIR /workspace/frontend
RUN if [ -f package-lock.json ]; then npm ci; elif [ -f pnpm-lock.yaml ]; then corepack enable && pnpm install --frozen-lockfile; elif [ -f yarn.lock ]; then corepack enable && yarn install --frozen-lockfile; elif [ -f package.json ]; then npm install; fi
RUN if [ -f package.json ]; then npm run build || true; fi
RUN mkdir -p /tmp/publish &&   if [ -d dist ]; then cp -R dist/. /tmp/publish/;   elif [ -d build ]; then cp -R build/. /tmp/publish/;   elif [ -d out ]; then cp -R out/. /tmp/publish/;   elif [ -d public ]; then cp -R public/. /tmp/publish/;   else echo "<!doctype html><html><body><h1>Deploy placeholder</h1></body></html>" > /tmp/publish/index.html; fi

FROM nginx:1.27-alpine
COPY --from=build /tmp/publish/ /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

