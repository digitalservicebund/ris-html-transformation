import com.github.gradle.node.npm.task.NpmTask

plugins {
    `java-library`
    `maven-publish`
    id("com.github.node-gradle.node") version "7.1.0"
}

group = "de.bund.digitalservice"
version = System.getenv("RELEASE_VERSION") ?: "0.0.1-SNAPSHOT"

repositories {
    mavenCentral()
}

node {
    version = "24.20.0"
    download = true
    nodeProjectDir = file("pdf-html-styling")
}

dependencies {
    compileOnly(libs.jetbrains.annotations)
    implementation(libs.log4j.api)
    implementation(libs.log4j.core)
    implementation(libs.saxon.he)
    implementation(libs.commons.io)

    testImplementation(libs.junit.jupiter.api)
    testImplementation(libs.junit.jupiter.params)
    testImplementation(libs.assertj.core)
    testImplementation(libs.jsoup)

    testRuntimeOnly(libs.junit.jupiter.engine)

    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}

tasks.test {
    useJUnitPlatform()
}

val buildCss by tasks.registering(NpmTask::class) {
    dependsOn(tasks.npmInstall)

    npmCommand.set(listOf("run", "build"))

    inputs.dir("pdf-html-styling/src")
    inputs.files(
        "pdf-html-styling/package.json",
        "pdf-html-styling/package-lock.json",
        "pdf-html-styling/vite.config.ts",
        "pdf-html-styling/postcss.config.ts",
        "pdf-html-styling/tsconfig.json",
    )
    outputs.dir("pdf-html-styling/dist")
}

tasks.processResources {
    dependsOn(buildCss)
    from("pdf-html-styling/dist") {
        include("style.css")
    }
}

publishing {
    publications {
        create<MavenPublication>("mavenJava") {
            from(components["java"])
        }
    }
    repositories {
        maven {
            name = "GitHubPackages"
            url = uri("https://maven.pkg.github.com/digitalservicebund/ris-html-transformation")
            credentials {
                username = System.getenv("GITHUB_ACTOR") ?: project.findProperty("gpr.user") as String?
                password = System.getenv("GITHUB_TOKEN") ?: project.findProperty("gpr.key") as String?
            }
        }
    }
}