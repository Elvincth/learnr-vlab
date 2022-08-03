"use strict";

const path = require("path");
const root = path.join(__dirname, "..");
const merge = require("webpack-merge");
const FileManagerPlugin = require("filemanager-webpack-plugin");

module.exports = (env) => {
    let config = {
        entry: "./src/index.ts",

        output: {
            filename: "vlab_bundle.js",
            path: path.join(root, "dist"),
        },

        resolve: {
            extensions: [".ts", ".js"],
        },

        module: {
            rules: [
                {
                    test: /\.(sa|sc|c)ss$/,
                    use: [
                        // Creates `style` nodes from JS strings
                        "style-loader",
                        // Translates CSS into CommonJS
                        "css-loader",
                        // Compiles Sass to CSS
                        "sass-loader",
                    ],
                },
                {
                    test: /\.(js|jsx|tsx|ts)$/,
                    exclude: /node_modules/,
                    use: "swc-loader",
                },
            ],
        },

        plugins: [
            new FileManagerPlugin({
                events: {
                    onEnd: {
                        copy: [
                            {
                                source: "./dist/",
                                destination: path.resolve(
                                    __dirname,
                                    "../../test/test-vlab/js/"
                                ),
                            },
                        ],
                    },
                },
            }),
        ],
    };

    // Builds
    const build = env && env.production ? "prod" : "dev";
    config = merge.merge(
        config,
        require(path.join(root, "webpack", "builds", `webpack.config.${build}`))
    );

    // // Addons
    // const addons = getAddons(env);
    // addons.forEach((addon) => {
    //     config = merge.merge(
    //         config,
    //         require(path.join(root, "webpack", "addons", `webpack.${addon}`))
    //     );
    // });

    console.log(`Build mode: \x1b[33m${config.mode}\x1b[0m`);

    return config;
};

// function getAddons(env) {
//     if (!env || !env.addons) return [];
//     if (typeof env.addons === "string") return env.addons.split(",");
//     return env.addons;
// }
