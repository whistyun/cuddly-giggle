const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    mode: "development",

    entry: {
        index: './src/index.ts'
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, 'dist'),
    },

    plugins: [
        new HtmlWebpackPlugin({
            template: path.resolve(__dirname, 'pages', 'index.html'),
            filename: 'index.html'
        })
    ],
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

    devServer: {
        port: 8080,
        contentBase: './dist',
        watchContentBase: true
    } 
};