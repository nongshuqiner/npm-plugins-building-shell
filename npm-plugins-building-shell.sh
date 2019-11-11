#!/usr/bin/env bash
# 构建 npm 插件

# 加载
echo "-------\033[36mloading\033[0m-------"

# npm 是否存在判断
npm -v 2>/dev/null 1>/dev/null # 2>/dev/null 1>/dev/null 把输出内容丢到黑洞里
if [ $? -ne 0 ]; then #
  echo "\033[36m程序已停止: npm 尚未安装，请安装后再试\033[0m"
  exit
fi

# 判断并创建npm本地存放的目录
if [ -d $HOME/Public ]; then
  cd $HOME/Public
  if [ ! -d $HOME/Public/mynpm ]; then
    mkdir mynpm
    echo "$HOME/Public/mynpm已经创建"
  fi
  cd $HOME/Public/mynpm
else
  cd $HOME
  mkdir Public && mkdir mynpm
  cd $HOME/Public/mynpm
fi

echo "\033[0;32m?\033[0m \033[36m请输入你的 npm 插件名(en:Project name)(必须为英文)：\033[0m"

read npmPluginsName

mkdir $npmPluginsName # 创建文件夹
cd $npmPluginsName # 进入文件
npm init
echo "\033[36m npm 初始化完成 \033[0m"

mkdir examples lib src test # 创建所需目录
touch .gitignore README.md npm-publish.sh # 创建所需文件
touch examples/index.html src/index.js test/index.js

# babel
echo "\033[36m is need babel？(Y/n):\033[0m"
read isNeedBabel
if [ "$isNeedBabel" = 'Y' -o "$isNeedBabel" = 'y' -o -z "$isNeedBabel" ]; then #
  # npm 安装
  npm install --save-dev babel-cli babel-preset-env
  npm install --save-dev babel-polyfill
  # 创建并且配置 .babelrc
  # echo "\033[36m 创建并且配置 .babelrc \033[0m"
  touch .babelrc
  cat <<EOF >.babelrc
{
  "presets": ["env"]
}
EOF
  echo "\033[36m babel\033[0m 安装成功"
fi

# git
echo "\033[36m is need git？(Y/n):\033[0m"
read isNeedGit
if [ "$isNeedGit" = 'Y' -o "$isNeedGit" = 'y' -o -z "$isNeedGit" ]; then #
  # git init
  git init
  echo "\033[36m git init \033[0m"
fi

# 配置 .gitignore
# echo "\033[36m 配置 .gitignore \033[0m"
cat <<EOF >.gitignore
.DS_Store
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Editor directories and files
.idea
.vscode
*.suo
*.ntvs*
*.njsproj
*.sln
EOF

# 配置 npm-publish.sh
# echo "\033[36m 配置 npm-publish.sh \033[0m"
cat <<EOF >npm-publish.sh
#!/usr/bin/env bash

echo "\033[0;32m?\033[0m \033[36m请输入你的新发布的版本号(ex:1.0.0)：\033[0m"

read version

# 处理 package.json
sed -i -e "s/\"version\": \(.*\)/\"version\": \"$version\",/g" 'package.json'
if [ -f "package.json-e" ];then
  rm 'package.json-e'
fi
echo '\033[36m版本号修改成功\033[0m'

npm config get registry # 检查仓库镜像库

npm config set registry=http://registry.npmjs.org # 设置仓库镜像库: 淘宝镜像https://registry.npm.taobao.org

echo '\033[36m请进行登录相关操作：\033[0m'

npm login # 登陆

echo "-------\033[36mpublishing\033[0m-------"

npm publish # 发布

npm config set registry=https://registry.npm.taobao.org # 设置为淘宝镜像

echo "\033[36m 完成 \033[0m"
exit
EOF

# 配置 README.md
# echo "\033[36m 配置 README.md \033[0m"
cat <<EOF >README.md
# XXX(组件名)

## 概述

...

## Install(安装)

npm install --save ...

## Usage(使用)

...

... 其他内容 ...

## Donation

...

## Contact me(联系我)

...

## License

[MIT](http://opensource.org/licenses/MIT) Copyright (c) 2018 - forever Naufal Rabbani
EOF


# 配置 examples/index.html
# echo "\033[36m 配置 examples/index.html \033[0m"
cat <<EOF >examples/index.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>$npmPluginsName</title>
  </head>
  <body>
    <div id="examples">
    </div>
    <!-- <script src="../lib/index.js"></script> -->
    <script>
      // 此处是代码...
    </script>
  </body>
</html>
EOF

# 配置 src/index.js
# echo "\033[36m 配置 src/index.js \033[0m"
cat <<EOF >src/index.js
(function (root, pluginName, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD:
    define(factory()); // define([], factory);
  } else if (typeof module === 'object' && module.exports) {
    // Node:
    module.exports = factory();
    // Use module export as simulated ES6 default export:(将模块导出用作模拟ES6默认导出)
    module.exports.default = module.exports;
  } else {
    // Browser:
    if (root === undefined) {
      root = typeof global !== "undefined" ? global : window
    }
    root[pluginName] = factory();
  }
}(this, 'myPluginName', function () {
  'use strict';

  // 方法类库
  return function (data) {}
  // 对象类库
  // var myPlugin = {};
  // return myPlugin
}));
EOF

# test 单元测试
echo "\033[36m is need mocha+chai test library？(Y/n):\033[0m"
read isNeedTest
if [ "$isNeedTest" = 'Y' -o "$isNeedTest" = 'y' -o -z "$isNeedTest" ]; then #
  # npm 安装
  npm install --save-dev mocha chai
  # 配置 test/index.js
  cat <<EOF >test/index.js
// 断言库 chai.js
var expect = require('chai').expect;

// 测试脚本里面应该包括一个或多个describe块，称为测试套件（test suite）
describe('这是一个测试套件', function () {
  // 每个describe块应该包括一个或多个it块，称为测试用例（test case）
  it('这是一个测试用例', () => {
    // 断言
    expect(1 + 1).to.equal(2); // 1+1=2
  });
});
EOF
  echo "\033[36m test 单元测试相关配置完成 \033[0m"
fi

echo "\033[36m 完成 \033[0m"
