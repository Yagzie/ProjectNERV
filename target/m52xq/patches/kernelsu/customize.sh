SKIPUNZIP=1

# [
KERNELSU_ZIP="https://github.com/saadelasfur/android_kernel_samsung_sm7325/releases/download/20250605/KSU_v1.0.5-20250605_m52xq_OneUI.zip"
KERNELSU_MANAGER_APK="https://github.com/tiann/KernelSU/releases/download/v1.0.5/KernelSU_v1.0.5_12081-release.apk"

REPLACE_KERNEL_BINARIES()
{
    [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    echo "Downloading $(basename "$KERNELSU_ZIP")"
    curl -L -s -o "$TMP_DIR/ksu.zip" "$KERNELSU_ZIP"

    echo "Extracting kernel binaries"
    rm -f "$WORK_DIR/kernel/"*.img
    unzip -q -j "$TMP_DIR/ksu.zip" \
        "mesa/boot.img" "mesa/dtbo.img" "mesa/vendor_boot.img" \
        -d "$WORK_DIR/kernel"

    echo "Extracting kernel modules"
    rm -f "$WORK_DIR/vendor/bin/vendor_modprobe.sh"
    DELETE_FROM_WORK_DIR "vendor" "lib/modules/5.4-gki"
    rm -rf "$WORK_DIR/vendor/lib/modules/"*
    unzip -q -j "$TMP_DIR/ksu.zip" \
        "vendor/bin/vendor_modprobe.sh" -d "$WORK_DIR/vendor/bin"
    unzip -q -j "$TMP_DIR/ksu.zip" \
        "vendor/lib/modules/*" -d "$WORK_DIR/vendor/lib/modules"

    sed -i "/qca_cld3_/d" "$WORK_DIR/configs/file_context-vendor"
    sed -i "/qca_cld3_/d" "$WORK_DIR/configs/fs_config-vendor"
    if ! grep -q "wlan\.ko" "$WORK_DIR/configs/file_context-vendor"; then
        echo "/vendor/lib/modules/wlan\.ko u:object_r:vendor_file:s0" >> "$WORK_DIR/configs/file_context-vendor"
    fi
    if ! grep -q "wlan.ko" "$WORK_DIR/configs/fs_config-vendor"; then
        echo "vendor/lib/modules/wlan.ko 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-vendor"
    fi

    rm -rf "$TMP_DIR"
}

ADD_MANAGER_APK_TO_PRELOAD()
{
    # https://github.com/tiann/KernelSU/issues/886
    local APK_PATH="system/preload/KernelSU/me.weishu.kernelsu-mesa==/base.apk"

    echo "Adding KernelSU.apk to preload apps"
    mkdir -p "$WORK_DIR/system/$(dirname "$APK_PATH")"
    curl -L -s -o "$WORK_DIR/system/$APK_PATH" -z "$WORK_DIR/system/$APK_PATH" "$KERNELSU_MANAGER_APK"

    sed -i "/system\/preload/d" "$WORK_DIR/configs/fs_config-system" \
        && sed -i "/system\/preload/d" "$WORK_DIR/configs/file_context-system"
    while read -r i; do
        FILE="$(echo -n "$i"| sed "s.$WORK_DIR/system/..")"
        [ -d "$i" ] && echo "$FILE 0 0 755 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-system"
        [ -f "$i" ] && echo "$FILE 0 0 644 capabilities=0x0" >> "$WORK_DIR/configs/fs_config-system"
        FILE="$(echo -n "$FILE" | sed 's/\./\\./g')"
        echo "/$FILE u:object_r:system_file:s0" >> "$WORK_DIR/configs/file_context-system"
    done <<< "$(find "$WORK_DIR/system/system/preload")"

    rm -f "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt"
    while read -r i; do
        FILE="$(echo "$i" | sed "s.$WORK_DIR/system..")"
        echo "$FILE" >> "$WORK_DIR/system/system/etc/vpl_apks_count_list.txt"
    done <<< "$(find "$WORK_DIR/system/system/preload" -name "*.apk" | sort)"
}
# ]

REPLACE_KERNEL_BINARIES
ADD_MANAGER_APK_TO_PRELOAD
