## Migration Guides

### Migrating from versions < 3.1.0

- `ALKConfiguration.hideContactInChatBar`, has been deprecated. Use `ALKConfiguration.chatBar.showOptions` to only show some options.

    ```swift
    config.optionsToShow = .some([.gallery, .location, .camera, .video])
    ```
- `ALKConfiguration.hideAllOptionsInChatBar` has been deprecated. Use `ALKConfiguration.chatBar.showOptions` to hide the all attachment options.

    ```swift
    configuration.chatBar.optionsToShow = .none
    ```