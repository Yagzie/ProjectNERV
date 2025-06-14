echo "Fix up /product/etc/build.prop"
sed -i "/# Removed by /d" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/#bluetooth./bluetooth./g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "s/?=/=/g" "$WORK_DIR/product/etc/build.prop" \
    && sed -i "$(sed -n "/provisioning.hostname/=" "$WORK_DIR/product/etc/build.prop" | sed "2p;d")d" "$WORK_DIR/product/etc/build.prop"

echo "Enable adaptive FPS"
SET_PROP "vendor" "ro.surface_flinger.use_content_detection_for_refresh_rate" "true"
sed -i \
    "/use_content_detection/a ro.surface_flinger.set_idle_timer_ms=3000\nro.surface_flinger.set_touch_timer_ms=500\nro.surface_flinger.set_display_power_timer_ms=1000" \
    "$WORK_DIR/vendor/default.prop"

echo "Add erofs to fstab"
sed -i \
  -e '/^system[[:space:]]\+\/system[[:space:]]\+\(erofs\|f2fs\)/d' \
  -e '/^\(system[[:space:]]\+\/system[[:space:]]\+\)ext4\([[:space:]].*\)$/s//\1ext4\2\n\1erofs\2\n\1f2fs\2/' \
  -e '/^\(\(system_ext\|vendor\|product\|odm\)[[:space:]]\+\/\2[[:space:]]\+\)f2fs\([[:space:]].*\)$/s//\1ext4\3\n\1erofs\3\n\1f2fs\3/' \
  $WORK_DIR/vendor/etc/fstab.qcom $WORK_DIR/vendor/etc/fstab.emmc

echo "Replacing kernel"
rm -f "$WORK_DIR/kernel/boot.img"
rm -f "$WORK_DIR/kernel/dtbo.img"
rm -f "$WORK_DIR/kernel/vendor_boot.img"
cp -rf "$SRC_DIR/prebuilts/kernels/a73xq/"*.img "$WORK_DIR/kernel/"
