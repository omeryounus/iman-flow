allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Fix for namespace issues with older Flutter plugins
// Fix for namespace issues and JVM mismatch with older Flutter plugins
subprojects {
    val configurePlugins = {
        val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        
        // Fix namespace
        if (project.name == "ar_flutter_plugin") {
            android?.namespace = "io.carius.lars.ar_flutter_plugin"
        }
        if (project.name == "flutter_compass") {
            android?.namespace = "com.hemanthraj.fluttercompass"
        }
        if (project.name == "flutter_qiblah") {
            android?.namespace = "ml.medyas.flutter_qiblah"
        }

        // Fix JVM mismatch (force Java 17)
        try {
            android?.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        } catch (e: Exception) {
            // Check if property is finalized or other error, ignore if so as it might be already set
            println("Could not set compileOptions for ${project.name}: ${e.message}")
        }
        
        project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }

    if (project.state.executed) {
        configurePlugins()
    } else {
        project.afterEvaluate {
            configurePlugins()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
