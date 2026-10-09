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

    // Namespace sorununu tip bağımlılığı olmadan çözen güvenli yöntem:
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android")
            try {
                // Namespace boşsa zorla ata
                val getNamespace = android.javaClass.getMethod("getNamespace")
                if (getNamespace.invoke(android) == null) {
                    val setNamespace = android.javaClass.getMethod("setNamespace", String::class.java)
                    // ... ilgili blok içindeki satır:
                    setNamespace.invoke(android, "com.vladih.computer_vision.flutter_vision")
                }
            } catch (e: Exception) {
                // Eğer metod bulunamazsa hata vermemesi için boş bıraktık
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}