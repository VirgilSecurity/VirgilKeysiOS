# Exporting Virgil Key

This guide shows how to export a **Virgil Key** to the string representation.

Before you begin to export a Virgil Key, set up your project environment with the [getting started](/docs/objectivec/guides/configuration/client.md) guide.

To export the Virgil Key:

- Initialize **Virgil SDK**

```objectivec
VSSVirgilApi *virgil = [[VSSVirgilApi alloc]
  initWithToken:@"[YOUR_ACCESS_TOKEN_HERE]"];
```

- Alice Generates a Virgil Key
- After Virgil Key generated, developers can export Alice's Virgil Key to a Base64 encoded string

```objectivec
// generate a new Virgil Key
VSSVirgilKey *aliceKey = [virgil.keys generateKey];

// export the Virgil Key
NSString *exportedAliceKey = [aliceKey
  exportWithPassword:@"[OPTIONAL_KEY_PASSWORD]"]
  base64EncodedStringWithOptions:0];
```

Developers also can extract Public Key from a Private Key using the Virgil CLI.