#!/bin/bash
set -ex

# If neither build target is selected
if [ $should_build_android != true && $should_build_ios != true ]; then
    # Technically the step ran successfully, but don't continue with Unity Editor download
    exit 0
fi

if [ ! -z $installer_id ]; then
    # If no Installer ID is specified, use the latest version
    base_url="https://download.unity3d.com/download_unity"
else
    base_url="https://download.unity3d.com/download_unity/${installer_id}"
fi

# Check to see if the unity package is already in this directory
if [ ! -f ./unity.pkg ]; then
    url="${base_url}/MacEditorInstaller/Unity.pkg"
    echo "Downloading Unity Editor package from ${url}..."
    curl -o ./unity.pkg $url
fi

# Check to see if the ios package is already in this directory
if [ $should_build_ios = true && ! -f ./ios.pkg ]; then
    url="${base_url}/MacEditorTargetInstaller/UnitySetup-iOS-Support-for-Editor.pkg"
    echo "Downloading Unity iOS Target Support package from ${url}..."
    curl -o ./ios.pkg $url
fi

# Check to see if the android package is already in this directory
if [ $should_build_android = true && ! -f ./android.pkg ]; then
    url="${base_url}/MacEditorTargetInstaller/UnitySetup-iOS-Support-for-Editor.pkg"
    echo "Downloading Unity Android Target Support package from ${url}..."
    curl -o ./ios.pkg $url
fi

# Install Unity Editor
if [ -f ./unity.pkg ]; then
    sudo -S installer -package ./unity.pkg -target / -verbose
else
    # If we made it here, the Unity Editor package didn't download, which is not good
    exit 1
fi

# Install iOS Target Support
if [ -f ./ios.pkg ]; then
    sudo -S installer -package ./ios.pkg -target / -verbose
elif [ $should_build_ios = true ]; then
    # If we made it here, that means we expected ios.pkg to download but didn't find it
    exit 1
fi

# Install Android Target Support
if [ -f ./android.pkg ]; then
    sudo -S installer -package ./android.pkg -target / -verbose
elif [ $should_build_android = true ]; then
    # If we made it here, that means we expected android.pkg to download but didn't find it
    exit 1
fi

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