if [ ! -f "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" ]; then
    [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    unzip -q -j "$WORK_DIR/system/system/apex/com.android.btservices.apex" \
        "apex_payload.img" -d "$TMP_DIR"

    mkdir -p "$TMP_DIR/tmp_out"
    sudo mount -o ro "$TMP_DIR/apex_payload.img" "$TMP_DIR/tmp_out"
    sudo cat "$TMP_DIR/tmp_out/lib64/libbluetooth_jni.so" > "$WORK_DIR/system/system/lib64/libbluetooth_jni.so"

    sudo umount "$TMP_DIR/tmp_out"
    rm -rf "$TMP_DIR"

    SET_METADATA "system" "system/lib64/libbluetooth_jni.so" 0 0 644 "u:object_r:system_lib_file:s0"
fi

# https://github.com/3arthur6/BluetoothLibraryPatcher/blob/e22da26ae7eb0856f1342bb565e6aa26a5ccaa73/hexpatch.sh#L12
HEX_PATCH "$WORK_DIR/system/system/lib64/libbluetooth_jni.so" \
    "480500352800805228" "530100142800805228"
