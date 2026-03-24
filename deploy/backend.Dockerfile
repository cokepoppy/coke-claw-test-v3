FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace
COPY . .
WORKDIR /workspace/backend
RUN if [ -f mvnw ]; then chmod +x mvnw && ./mvnw -DskipTests package; elif [ -f pom.xml ]; then mvn -DskipTests package; elif [ -f gradlew ]; then chmod +x gradlew && ./gradlew build -x test; elif [ -f package.json ]; then npm ci && npm run build; fi
RUN mkdir -p /tmp/backend-artifacts &&   if ls target/*.jar >/dev/null 2>&1; then cp target/*.jar /tmp/backend-artifacts/app.jar;   elif ls build/libs/*.jar >/dev/null 2>&1; then cp build/libs/*.jar /tmp/backend-artifacts/app.jar;   else printf 'No backend artifact found.\n' > /tmp/backend-artifacts/README.txt; fi

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /tmp/backend-artifacts/ /app/
EXPOSE 8080
CMD ["java", "-jar", "/app/app.jar"]

