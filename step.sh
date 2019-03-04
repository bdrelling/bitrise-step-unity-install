#!/bin/bash
set -ex

# If neither build target was selected
if [[ "$should_build_android" != true && "$should_build_ios" != true ]]; then
    # Technically the step ran successfully, but don't continue with Unity Editor download
    exit 0
fi

# Strip trailing / from package directory
package_directory=${package_directory%/}

# If no value is provided for package directory, set it to the default
if [ -z $package_directory ]; then
    package_directory="unity_packages"
fi

# Package paths for convenience
unity_editor_package_path="{$package_directory}/unity.pkg"
ios_package_path="{$package_directory}/ios.pkg"
android_package_path="{$package_directory}/android.pkg"

if [ ! -z $installer_id ]; then
    # If no Installer ID is specified, use the latest version
    base_url="https://download.unity3d.com/download_unity"
else
    base_url="https://download.unity3d.com/download_unity/${installer_id}"
fi

# Download Unity Editor
# If the Unity package isn't already in the root, download it
if [ ! -f ./unity.pkg ]; then
    url="${base_url}/MacEditorInstaller/Unity.pkg"
    echo "Downloading Unity Editor package from ${url}..."
    curl -o $unity_editor_package_path $url
fi

# Download iOS Target Support
# If we want to build iOS and the package isn't already in the root, download it
if [[ "$should_build_ios" = true && ! -f ./ios.pkg ]]; then
    url="${base_url}/MacEditorTargetInstaller/UnitySetup-iOS-Support-for-Editor.pkg"
    echo "Downloading Unity iOS Target Support package from ${url}..."
    curl -o $ios_package_path $url
fi

# Download Android Target Support
# If we want to build Android and the package isn't already in the root, download it
if [[ "$should_build_android" = true && ! -f ./android.pkg ]]; then
    url="${base_url}/MacEditorTargetInstaller/UnitySetup-iOS-Support-for-Editor.pkg"
    echo "Downloading Unity Android Target Support package from ${url}..."
    curl -o $android_package_path $url
fi

# Install Unity Editor
if [ -f $unity_editor_package_path ]; then
    sudo -S installer -package $unity_editor_package_path -target / -verbose
else
    # If we made it here, the Unity Editor package didn't download, which is not good
    exit 1
fi

# Install iOS Target Support
if [[ "$should_build_ios" = true && -f $ios_package_path ]]; then
    sudo -S installer -package $ios_package_path -target / -verbose
elif [ $should_build_ios = true ]; then
    # If we made it here, that means we expected ios.pkg to download but didn't find it
    exit 1
fi

# Install Android Target Support
if [[ "$should_build_android" = true && -f $android_package_path ]]; then
    sudo -S installer -package $android_package_path -target / -verbose
elif [ $should_build_android = true ]; then
    # If we made it here, that means we expected android.pkg to download but didn't find it
    exit 1
fi

# Export the unity package paths for usage in other steps (like caching)
envman add --key UNITY_PACKAGE_DIRECTORY --value $package_directory
envman add --key UNITY_EDITOR_PACKAGE_PATH --value $unity_editor_package_path
envman add --key UNIT_IOS_PACKAGE_PATH --value $ios_package_path
envman add --key UNITY_ANDROID_PACKAGE_PATH --value $android_package_path

exit 0

# #
# # --- Export Environment Variables for other Steps:
# # You can export Environment Variables for other Steps with
# #  envman, which is automatically installed by `bitrise setup`.
# # A very simple example:
# envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# # Envman can handle piped inputs, which is useful if the text you want to
# # share is complex and you don't want to deal with proper bash escaping:
# #  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# # You can find more usage examples on envman's GitHub page
# #  at: https://github.com/bitrise-io/envman