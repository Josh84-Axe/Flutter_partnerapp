import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("partner") {
            dimension = "flavor-type"
            applicationId = "com.tiknet.partner"
            resValue(type = "string", name = "app_name", value = "Tiknet Partner")
        }
        create("family") {
            dimension = "flavor-type"
            applicationId = "com.tiknet.family"
            resValue(type = "string", name = "app_name", value = "Tiknet Family")
        }
        create("campus") {
            dimension = "flavor-type"
            applicationId = "com.tiknet.campus"
            resValue(type = "string", name = "app_name", value = "Tiknet Campus")
        }
    }

    buildFeatures.resValues = true
}