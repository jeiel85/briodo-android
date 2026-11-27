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
// home_widget 0.9.1 은 androidx.work:work-runtime-ktx:2.+ 를 동적 버전으로 받는다. 2.12.0(JVM 11 대상 inline 함수)이
// 끌려오면 그 플러그인(jvmTarget 1.8)의 compileReleaseKotlin 이 "Cannot inline bytecode built with JVM target 11" 로
// 깨진다. 플러그인 모듈의 클래스패스에도 걸리도록 app 이 아니라 모든 서브프로젝트에서 v1.5.3까지 쓰던 2.10.1 로 강제한다.
subprojects {
    configurations.all {
        resolutionStrategy {
            force("androidx.work:work-runtime:2.10.1")
            force("androidx.work:work-runtime-ktx:2.10.1")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
