exports('UiFeedClearHelpTextFeed', (duration, text) => {
    const struct1 = new DataView(new ArrayBuffer(96));
    struct1.setInt32(0 * 8, duration, true);

    const struct2 = new DataView(new ArrayBuffer(64));
    struct2.setBigInt64(1 * 8, BigInt(CreateVarString(10, "LITERAL_STRING", text)), true);

    const id = Citizen.invokeNative("0x049D5C615BD38BAD", struct1, struct2, 1, 1);
    // setTimeout(() => {
    //     Citizen.invokeNative("0x2F901291EF177B02", id, true);
    // }, 1000);
});