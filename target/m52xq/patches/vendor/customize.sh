echo "Updating MIDAS [A73XQ]"
DELETE_FROM_WORK_DIR "vendor" "etc/midas"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "etc/midas"

echo "Fix MIDAS model detection [m52xq --> a73xq]"
sed -i "s/m52xq/dummy/g" "$WORK_DIR/vendor/etc/midas/midas_config.json"
sed -i "s/a73xq/m52xq/g" "$WORK_DIR/vendor/etc/midas/midas_config.json"
sed -i "s/ro.product.device/ro.product.vendor.device/g" "$WORK_DIR/vendor/etc/midas/midas_config.json"

if ! grep -q "vendor_firmware_file (file (mounton" "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"; then
    echo "(allow init_30_0 vendor_firmware_file (file (mounton)))" >> "$WORK_DIR/vendor/etc/selinux/vendor_sepolicy.cil"
fi

echo "Updating Face HAL... [2.0 --> 3.0]"
BLOBS_LIST="
bin/hw/vendor.samsung.hardware.biometrics.face@2.0-service
etc/init/vendor.samsung.hardware.biometrics.face@2.0-service.rc
"
for blob in $BLOBS_LIST
do
    DELETE_FROM_WORK_DIR "vendor" "$blob"
done

ADD_TO_WORK_DIR "a73xqxx" "vendor" "bin/hw/vendor.samsung.hardware.biometrics.face@3.0-service"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "etc/init/vendor.samsung.hardware.biometrics.face@3.0-service.rc"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "lib/vendor.samsung.hardware.biometrics.face@2.0.so"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "lib/vendor.samsung.hardware.biometrics.face@3.0.so"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "lib64/vendor.samsung.hardware.biometrics.face@2.0.so"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "lib64/vendor.samsung.hardware.biometrics.face@3.0.so"

echo "wpa_supplicant for One UI 7 [A73XQ]"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "bin/hw/wpa_supplicant"

echo "Fixing brightness [Light HAL from A73XQ]"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "bin/hw/vendor.samsung.hardware.light-service"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "lib64/android.hardware.light-V1-ndk_platform.so"
ADD_TO_WORK_DIR "a73xqxx" "vendor" "lib64/vendor.samsung.hardware.light-V1-ndk_platform.so"