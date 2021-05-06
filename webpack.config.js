const path = require('path');

module.exports = {
    entry: {
        index: './src/index.ts'
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, 'dist'),
    },
    module: {
        rules: [
            {
                test: /\.ts$/,
                exclude: /node_modules/,
                loader: "ts-loader"
            },
            {
                test: /\.pegjs$/,
                exclude: /node_modules/,
                loader: "pegjs-loader"
            },
        ]
    },
    resolve: {
        extensions: ['.ts', '.js', '.json', '.pegjs'],
        modules: ['node_modules'],
    },

    mode: "development",
};