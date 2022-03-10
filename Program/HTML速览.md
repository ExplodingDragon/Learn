# HTML

> 记录关于 `HTML` 知识的学习

## HTML Hello World

一个标准的 HTML 如下所示：

```html
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>Hello World</title>
</head>
<body>

<h1>H1 标签</h1>
<h2>H2 标签</h2>
<h3>H3 标签</h3>
<h4>H4 标签</h4>
<h5><font color="red">H5 标签</font> </h5>
<h6>H6 标签</h6>
<p>P 标签</p>
</body>
</html>
```

## HEADER  头

### HTML5头部

```html
<!DOCTYPE html>
```

### 加入编码格式

``` html
<meta charset="utf-8">
```

### 标题

```html
<title>title</title>
```

### META

#### keywords

表示关键字，多个关键字使用`,`隔开

```html
    <meta name="keywords" content="html5,css3">
```

#### description

网站描述

```html
<meta name="description" content="描述">

```

#### http-equiv

与 HTTP 协议相关

```html
<meta http-equiv="refresh" content="3;url=https://www.baidu.com">
<!--
  重定向
-->
```

## BODY

 在 HTML 显示特殊字符

|显示|代码|
|:----:|:----:|
| " "|`&nbsp;` |
| © |`&copy`|
|\>| `&gt`|
|<| `&lt`|

[更多](https://www.jb51.net/onlineread/htmlchar.htm)

### 元素

#### 块元素

> 在页面独占一行的元素叫块元素 （block  element）

 主要用来布局

#### 行内元素

> 不会独占一行的称为行内元素 (inline element)

主要用来包裹文字 (设置特殊效果)

### 标签

#### 标题标签

权重

建议： h1 只有一个

```html
<h1>一级标题</h1>
<h2>二级标题</h2>
<h3>三级标题</h3>
<h4>四级标题</h4>
<h5>五级标题</h5>
<h6>六级标题</h6>
```

#### 段落标签

表示一个段落

```html
<p>段落标签</p>
```

#### hgroup

用来为标题分组

```html
<hgroup>
<h1>一级标题</h1>
<h2>二级标题</h2>
</hgroup>
```

#### em

表示加重 (斜体)

```html
<p>HhHHhH<em>OK</em>,</p>
```

#### strong

表示强调 (粗体)

```html
<p>HhHHhH<strong>OK</strong>,</p>
```

#### blockquote

表示引用内容 ,长引用，块元素

```html
<blockquote>
 引用内容
</blockquote>
```

#### q

表示引用内容 ,短引用

```html
<p>HhHHhH<q>OK</q>,</p>
```

#### br

换行

```html
<br>
```

#### header

表示网页的头部

```html
<header></header>
```

#### main

表示网页的主体 (只有一个)

```html
<main></main>
```

#### footer

表示网页的底部

```html
<footer></footer>
```

#### nav

表示网页的导航

```html
<nav></nav>
```

#### aside

表示和主体相关的内容

```html
<aside></aside>
```

#### article

表示一篇文章

```html
<article></article>
```

#### section

表示一个独立的区块

```html
<section></section>
```

#### div

表示一个区块

```html
<div></div>
```

#### span

行内元素

```html
<span></span>
```

#### 列表

> 可以嵌套

##### 无序列表

```html
<ul>
<li>ITEM1</li>
<li>ITEM2</li>
<li>ITEM3</li>
</ul>
```

##### 有序列表

```html
<ol>
<li>ITEM1</li>
<li>ITEM2</li>
<li>ITEM3</li>
</ol>
```

##### 定义列表

```html
<dl>
<dt>ITEM1</dt>
<dd>这是解释</dd>
</dl>
```

#### 超链接

  从一个页面跳转到另一个页面

  可以嵌套其他元素

- href:
  - 可以是外部
  - 可以是内部
- target:
  - _self:  当前页打开
  - _blank: 新页打开

 ``` html
<a href="https://www.baidu.com">百度</a>
<a href="#bottom">BOTTOM</a>
<a href="#ITEM">ITEM</a>
<a href="https://www.baidu.com" target="_blank">百度</a>
<a href="https://www.baidu.com">百度</a>
<a href="https://www.baidu.com">百度</a>
<a href="https://www.baidu.com">百度</a>
<a id="bottom" href="#">TOP</a>
<a  href="javascript:;">Empty LINK</a>
 ```

#### 图片标签

img  属于替换元素

- alt: 表示描述，搜索引擎会根据 alt 内容来识别图片类型
- width: 宽度 (像素)
- height: 高度 (像素)

一般情况下,PC 不建议修该图片大小 ，而移动端经常需要对图片进行缩放

```html
<img src="img/favicon.ico" >
<img src="img/favicon.ico" alt="LOADING">
<img src="data:image/jpeg;base64,......">
```

#### 内联框架 （iframe）

- src: 引入网页的路径
- frameborder: 是否显示边框

```html
<iframe src="https://www.baidu.com" frameborder="0" width="900" height="600"></iframe>
```

#### 音频

默认是无法控制的

- controls : 是否允许用户控制
- autoplay :  开启自动播放
- loop : 循环播放

```html
<audio src="media/music.mp3"></audio>
<audio src="media/music.mp3" controls></audio>
<audio src="media/music.mp3" controls autoplay></audio>
<audio src="media/music.mp3" controls autoplay loop></audio>
<audio controls>
     对不起，你的浏览器不支持
    <source src="media/music.mp3">
</audio>
<audio controls>
    <source src="media/music.mp3">
    <source src="media/music.ogg">
    <source src="media/music.flv">
</audio>


<audio controls>
    <source src="media/music.mp3">
    <source src="media/music.ogg">
    <source src="media/music.flv">
    <embed src="media/music.mp3" type="media/mp3" width="200" height="300">
</audio>

```

关于兼容 IE 8

```html
    <embed src="media/music.mp3" type="media/mp3" width="200" height="300">

```

#### 视频

和 `audio` 基本一样

```html
<video src="media/music.mp3"controls autoplay loop></video>
<video controls >
    <source src="media/music.mp3">
</video>
```

#### HTML5

##### `header`

头部标签

##### `main`

网页主体

##### `footer`

尾部

## 表格

```html
<body>
    <table border="1" width="50%" align="center">
        <tr>
            <td>asa</td>
            <td>asa</td>
            <td>asa</td>
            <td>sas</td>
        </tr>
        <tr>
            <td>asa</td>
            <td>asa</td>
            <td>sas</td>
            <td>sas</td>
        </tr>
        <tr>
            <td>asa</td>
            <td rowspan="2">asa</td>
            <!-- 合并纵向单元格 -->
            <td>asa</td>
            <td>sas</td>
        </tr>
        <tr>
            <td>asa</td>
            <td colspan="2">sas</td>
            <!-- 合并横向单元格 -->
        </tr>
    </table>
```

### 长表格

```html
    <table width="50%" align="center">
        <thead>
            <tr>
                <th>日期</th>
                <th>收入</th>
                <th>支出</th>
                <th>合计</th>
            </tr>
        </thead>
        <tbody align="center">
            <tr>
                <td>2020.1</td>
                <td>100</td>
                <td>100</td>
                <td>0</td>
            </tr>
            <tr>
                <td>2020.2</td>
                <td>100</td>
                <td>100</td>
                <td>0</td>
            </tr>

            <tr>
                <td>2020.3</td>
                <td>100</td>
                <td>100</td>
                <td>0</td>
            </tr>

            <tr>
                <td>2020.4</td>
                <td>100</td>
                <td>100</td>
                <td>0</td>
            </tr>

            <tr>
                <td>2020.5</td>
                <td>100</td>
                <td>100</td>
                <td>0</td>
            </tr>
        </tbody>
        <tfoot align="center">
            <tr>
                <th>合计</th>
                <td>500</td>
                <td>500</td>
                <td>0</td>
            </tr>
        </tfoot>
    </table>
```

## 表单

表单用于提交数据，在网页中的表单用于将本地的数据提交到远程的服务器

```html
    <form action="表单.html" method="get">
        <input type="text" value="" name="name">
        <!-- 文本框 -->
        <!-- 要提交数据，必须指定 name -->
        <br>
        <input type="password" value="" name="password">
        <!-- 密码框 -->
        <br>
        <input type="radio" name="radio" value="a" checked>
        <input type="radio" name="radio" value="b">
        <!-- 单选按钮 必须指定相同名字 ,指定它的value -->
        <br>
        <input type="checkbox" name="checkbox1" id="1" checked>
        <input type="checkbox" name="checkbox2" id="2">
        <input type="checkbox" name="checkbox3" id="3">
        <!-- 多选按钮 -->
        <br>
        <select name="select">
            <option value="1">1</option>
            <option value="2">2</option>
            <option value="3" selected>3</option>
            <!-- 下拉列表 -->
        </select>
        <input type="submit">
    </form>
```

```html
    <form action="表单2.html" method="get">
        <input type="text" name="name" value="默认值">
        <!-- 设置 value 表示默认值 -->
        <br>
        <br>
        <input type="button" value="按钮">
        <!-- 普通的按钮 -->
        <button type="button">普通的按钮2</button>
        <br>
        <br>
        <input type="reset" value="重置">
        <button type="reset">重置2</button>
        <!-- 重置按钮 -->
        <br>
        <br>
        <input type="color" name="color" value="#FFFFFF">
        <!-- 颜色选择 -->
        <input type="email" name="email">
        <!-- 会检测是否符合 -->
        <button type="submit"> 提交</button>
        <br>
        <input type="text" name="a" autocomplete="on">
        <!-- autocomplete 开启表单自动完成 -->
        <br>
        <input type="text" name="b" readonly value="read-only">
        <!-- readonly 表示设置为只读 -->
        <br>
        <input type="text" name="c" disabled value="disabled">
        <br>
        <!-- 表示禁用 -->
        <!-- 只读可以提交，但禁用不会提交 -->
        <input type="text" name="c" autofocus>
        <!--  autofocus 表示自动获取焦点 -->
    </form>
```
