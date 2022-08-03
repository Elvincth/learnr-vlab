interface Callback {
    (message: string): void;
}

interface Shiny {
    onInputChange(name: string, value: string, settings: Object): void;
    addCustomMessageHandler(msg: string, callback: Callback): void;
}

export {};

declare global {
    const Shiny: Shiny;
}
