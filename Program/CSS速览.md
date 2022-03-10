# CSS

- 声明块:由一个个声明组成
- 声明:由一个样式名对应一个样式值

## 元素添加样式

### 1. 通过标签内部 (内联)

开发时绝对不要使用

```html
<p style="fill: red">Hello World</p>
```

### 2. 编写到 `head` 下 (内部样式表)

```html
<head>
<style>
p{
    fill: red;
    color: red;
}
</style>
</head>
```

### 3. 外部样式表

> 可以使用浏览器缓存

```html
<head>
    <link rel="stylesheet" href="css/style.css">
</head>
```

## 注释

```css
/*

*/
```

## 选择器

通过选择器可以选中页面的指定元素

### 常用选择器

#### 元素选择器

根据标签名来选中所有指定元素

```css
p{
      color: red;
}
h1{
    color: blue;
}
```

#### ID 选择器

根据元素ID属性值来选中一个元素

```css
#item_2{
    color: green;
}
```

```html
<p id="item_2">苟利国家生死以，岂因祸福避趋之！</p>
```

#### CLASS 选择器

- 跟 ID 类似，但可以重复使用 （选中一组）
- 可以为同一个元素指定多个CLASS

 ``` html
<p class="item">谪居正是君恩厚，养拙刚于戍卒宜。</p>
<p class="item item2">戏与山妻谈故事，试吟断送老头皮。</p>
 ```

``` css
.item{
    color: antiquewhite;
}
.item2{
    font-size: 20px;
}
```

#### 通配选择器

选中页面所有元素

```css
*{
    width: auto;
}
```

#### 复合选择器

##### 交集选择器

选中同时符合多个条件的元素

**语法**： `选择器1选择器2选择器3` ......

```css
.green{
    color: green;
}
h2.green{
    font-size: 30px;
}
```

``` html
<h2 class="green">我是 H2</h2>
<p class="green">我是 P </p>
```

**注意**： 如果有元素选择器则必须使用元素选择器开头

##### 并集选择器

同时选择多个选择器对应的元素(满足一个)

**语法**：`选择器1,选择器2,选择器3` ......

```css
h2,p{
    text-align: center;
}
```

```html
<h2>我是 H2</h2>
<p>我是 P </p>
```

#### 关系选择器

- 父元素：
  - **直接**包含子元素的元素叫父元素
- 子元素：
  - **直接**被父元素包含的元素叫子元素
- 祖先元素：
  - **直接或间接**包含后代元素的元素叫祖先元素
  - 一个元素的父元素也是它的祖先元素
- 后代元素：
  - **直接或间接**被祖先元素包含的元素叫后代元素
  - 子元素也是后代元素
- 兄弟元素：
  - 拥有相同父元素的元素叫兄弟元素

```html
<div>
     我是 DIV
    <p>我是 DIV 下的 P
    <span>我是 P 下的 SPAN</span>
    </p>
    <span>我是 DIV 下的 SPAN</span>
</div>
```

##### 子元素选择器

选中指定父元素的指定子元素

语法：

- `父元素 > 子元素`
- `div.box > span` (可以混合使用)

```css
div > span {
    color: aqua;
}
```

##### 后代元素选择器

选中指定元素的指定后代

语法：

- `祖先元素 后代元素`

```css
p span{
    color: red;
}
```

##### 兄弟选择器

###### 选择下一个元素

选择当前元素的下**一个**元素

**语法**：

- `前一个 + 下一个`

```css
p + span{
    color: darkgreen;
}
```

###### 选择下面所有的元素

选择当前元素下面**所有**元素

**语法**：

- `前一个 ~ 下面所有`

```css
p ~ span{
    color: darkgreen;
}
```

##### 属性选择器

用法：

- `元素[属性名]`:选择含有指定属性的元素
- `元素[属性名=属性值]`:选择含有指定属性名和属性值的元素
- `元素[属性名^=属性值]`:选择属性值以指定值开头的元素
- `元素[属性名$=属性值]`:选择属性值以指定值结尾的元素
- `元素[属性名*=属性值]`:选择属性值中包含指定值的元素

```css
p[title]{
    color: red;
}
p[title=ha]{
    color: darkgreen;
}
p[title^=He]{
    font-size: large;
}
p[title$=ha]{
    font-size: small;
}
p[title*=a]{
    text-align: center;
}
```

```html
<p title="Hello">力微任重久神疲，再竭衰庸定不支。</p>
<p title="ha">苟利国家生死以，岂因祸福避趋之！</p>
<p>谪居正是君恩厚，养拙刚于戍卒宜。</p>
<p>戏与山妻谈故事，试吟断送老头皮。</p>
```

#### 伪类选择器

- 伪类用来描述一个元素的特殊状态
- 伪类一般情况下使用 `:`开头

**示例**：

- `:first-child`：第一个子元素
- `:last-child`：最后一个子元素
- `nth-child(n)`: 选中第n个元素 (如下是例子)
  - `n` :第n个 ， n的范围为0～正无穷大
  - `2n` 或 `even`:表示选中偶数位的元素
  - `2n+1`或 `odd`: 表示选中奇数位的元素

注意：以上这些伪类根据所有元素来排序

- `:first-of-type`
- `:last-of-type`
- `:first-of-type`
- `nth-of-type(n)`

而这些伪类和上面的类似，不同点是它们只在同类型元素排序

```css
    ul >li:first-child{
        color: red;
    }
    ul >li:last-child{
        color: green;
    }
    ul>li:nth-child(3){
        font-size: large;
    }
    ul>li:nth-child(n){
        text-align: center;
    }
    ul>li:nth-child(2n){
        text-align: right ;
    }
    ul>li:nth-child(2n+1){
        text-align: left ;
    }
    ul>li:nth-of-type(1){
        text-align: left ;
    }

```

```html
    <ul>
        <li>第一个</li>
        <li>第二个</li>
        <li>第三个</li>
        <li>第四个</li>
        <li>第五个</li>
    </ul>

```

- `:not(...)`  未测试！！！

#### 伪类 ( 2 )

##### `<a>`

`a:link` : 表示未访问过的链接 （正常的链接）

`a:visited`:  表示访问过的链接 （由于隐私的原因，只允许更改颜色）

##### 通用

`:hover`: 鼠标移入状态

`:active`:鼠标点击状态

```html
    <a href="https://www.baidu.com">baidu</a>
<br>
    <a href="https://www.baidu.com">baidu</a>

```

``` css

a:link{
    color: red;
}
a:visited{
    color: blue;
}
a:hover{
    font-size: 30px;
}
a:active{
    color: cadetblue;
}

```

#### 伪元素

表示特殊的并不存在的元素

- `::first-letter`: 表示第一个字母

- `::first-line`:表示第一行

- `::selection`:表示选择的内容

- `::before`:元素的开始

- `::after`:元素的最后

- 注意：`::before` 和 `::after` 要配合 `content`来使用

```css

p::first-letter{
    font-size: 50px;
}

p::first-line{
    color: chartreuse;
}
p::selection{
   color: red;
}
div::before{
content: 'abc ';
color: red;
}
div::after{
    content: 'after ';
color: blue;
}

```

```html

<div>safhsdhfahfkhsdf hosiadhfihasdhfksafhsdhfahfkhsdf hosiadhfihasdhfksafhsdhfahfkhsdf hosiadhfihasdhfksafhsdhfahfkhsdf hosiadhfihasdhfk</div>
<p>safhsdhfahfkhsdf hosiadhfihasdhfksafhsdhfahfkhsdf hosiadhfihasdhfksafhsdhfahfkhsdf hosiadhfihasdhfksafhsdhfahfkhsdf hosiadhfihasdhfk</p>

```

### 权重

样式冲突：

- 当不同的选择器选择相同的元素,并且为相同的样式设置不同的值,此时就发生了样式冲突
- 样式冲突时该使用的样式由选择器的权重决定

权重排序（由大到小）：

|     选择器     |   权重   |
| :------------: | :------: |
|    内联样式    | 1,0,0,0  |
|   id 选择器    | 0,1,0,0  |
| 类和伪类选择器 | 0,0,1,0  |
|   元素选择器   | 0,0,0,1  |
|   通配选择器   | 0,0,0,0  |
|   继承的样式   | 无优先级 |

- 比较优先级时,需要将所有选择器的优先级相加，最后优先级越高则越优先显示 (分组选择器是单独计算),
- 选择器累加不会超过其最大的数量级，例如类选择器叠加最大不会超过 ID 选择器
- 如果优先级相等,则优先使用靠下的样式

## 单位

### 长度单位

#### 像素: (单位：px)

- 同样的 200px 在不同的设备显示效果不一样

#### 百分比

- 百分比可以将属性值设置为父元素属性的百分比
- 设置百分比可以跟随父元素改变而改变

#### em

- em 是相对于元素的字体大小来计算的
- `1 em = 1 font-size`
  - em 会根据字体大小改变而改变

#### rem

- rem 是相对于根元素（html）的字体大小来计算的

### 颜色单位

> 在 CSS 中可以直接使用颜色名来设置各种颜色，但不方便

#### RGB值

- RGB 通过三种颜色的不同浓度来调配出不同的颜色
- R red、G green、B blue
- 范围：0 - 255
- 语法：
  - `RGB(红色,绿色,蓝色);`
  - `rgb(0,0,255);`
  - `rgb(0,255,0);`
  - `rgb(255,0,0);`
  - `rgb(255,124,243);`

#### RGBA值

- A : 表示透明
- 范围：0 - 1 (1 表示完全透明)
- 语法：
  - `RGB(红色,绿色,蓝色,透明);`
  - `rgb(0,0,255,0);`
  - `rgb(0,255,0,0.5);`
  - `rgb(255,0,0,1);`
  - `rgb(255,124,243,0.2);`

#### 十六进制RGB值

- 语法：`#红色绿色蓝色`
- 范围：00 - FF
- 如果两位重复可以简写
  - （`#AABBCC` -> `#ABC`）
  - `#212134`
  - `#66CCFF`
  - `#BBFFAA`
  - `#bfa`

#### HSLA 值

- H: 色相 (0 - 360)
- S: 饱和度 (0% - 100%)
- L: 亮度 (0% - 100%)

```css
div{
background: hsl(360,100%,15%);
}
```

## 布局

### 文档流

- 网页是一个多层结构
- 通过css可以分别为每一层来设置样式
- 用户只能看到最顶层
- 这些层中最底下一层称为文档流,是网页的基础
- 我们所创建的元素默认都是文档流中进行排列
- 元素有两个状态：
  - 在文档流中
  - 不在文档流中
- 元素在文档流中的特点
  - 块元素
    - 会在页面中独占一行
    - 默认宽度是父元素的全部（把父元素撑满）
    - 默认高度是被子元素撑开
  - 行内元素
    - 行内元素不会独占一行,只占自身大小
    - 行内元素会自左向右水平排列, 如果一行无法容纳所有行内元素，则元素会换到第二行继续自左向右排列（和书写习惯相似）
    - 行内元素默认寬高被内容撑开

### 盒模型 (box model)

- CSS 将页面的所有元素都设置为一个矩形的盒子
- 将元素设置为矩形的盒子后，对页面的布局就变成了把盒子摆放到不同的位置
- 每个盒子都由以下几个部分组成:
  - 内容区 (content)
  - 内边距 (padding)
  - 边框 (border)
  - 外边距 (margin)

#### 内容区

元素中所有子元素都在内容区排列，
内容区的大小由 `width` 和 `height`来设置

#### 边框

边框属于盒子的边缘，边框里为盒子内部

> 边框的大小会影响盒子的大小

要设置边框至少要设置三个样式：

- 边框的宽度：`border-width`
  - 可以指定四个方向的宽度 (上、右、下、左)
  - 可以指定三个方向的宽度 (上、左右、下)
  - 可以指定两个方向的宽度 (上下、左右)
  - 可以指定一个方向的宽度 (上下左右)
  - 除了 `border-width` ，还有一组 `border-xxx-width`
    - `border-top-width`
    - `border-bottom-width`
    - `border-left-width`
    - `border-right-width`
- 边框的颜色: `border-color`
  - 可以指定四个边框的值 （上、右、下、左）
  - 不指定则默认使用 `color` 的值
- 边框的样式：`border-style`
  - `solid` :实线
  - `dotted`:点状虚线
  - `dashed`: 虚线
  - `double`: 双线
  - 它的默认值为 `none`

border简写: `border: solid 10px orange`
他也有 `border-top`、`border-left` ...

```css

    .div1{
            width: 100px;
            height: 100px;
            background-color: red;
            border-width: 1px;
            border-color: blue;
            border-style: solid;
        }
```

#### 内边距

内容区与边框的距离叫做内边距

> 内边距会影响盒子的大小，背景颜色会延伸到内边距上

- `padding`
- `padding-top`
- `padding-bottom`
- `padding-right`
- `padding-left`

#### 外边距

> 外边距不会影响可见框的大小，但会影响盒子的位置

- `margin`
- `margin-top`
  - 上外边距：设置一个正值，元素向下移动
- `margin-right`
  - 默认情况下不会产生任何效果
- `margin-bottom`
  - 下外边距：设置一个正值，其下边的元素则会向下移动
- `margin-left`
  - 左外边距：设置一个正值，元素向右移动

**解释**：

- margin 也可以设置一个负数,如果为负值则会向相反的方向移动
- 元素在页面中是按照自左向右的顺序排列的，
- 所以默认情况下如果们设置左边和上面会移动自己，而
- 右边和下边则会移动其他的元素
- margin 会影响盒子实际占用的空间

##### 垂直方向相邻外边距的重叠

相邻的垂直方向外边距会发生重叠现象

- 兄弟元素
  - 取两者之间的较大值(都是正值)
  - 如果相邻的外边距一正一负，则取两者的和
  - 如果相邻的外边距都是负数，则取绝对值较大的
  - 兄弟元素之间的外边距的重叠，对于开发是有利的，不需要处理

- 父子元素
  - 父子元素间相邻外边距，子元素会传递给父元素（上外边据）
  - 会影响到页面的布局，必须要处理
    - 不用 `margin-top`，用 `padding-top`

#### 盒子水平方向布局

元素在其父布局水平方向的位置由以下几个属性共同决定:

- `margin-left`
- `border-left`
- `padding-left`
- `width`
- `padding-right`
- `border-right`
- `margin-right`

一个元素在其父元素中，水平布局必须满足以下等式：

`margin-left` +
`border-left`+
`padding-left`+
`width`+
`padding-right`+
`border-right`+
`margin-right` = 其父元素内容区的宽度 （必须）

如果计算结果使等式不成立，称为过度约束，则等式会自动调整，如果值中没有 `auto`
的情况，则浏览器会自动调整 `margin-right`

这三个值可以设置成 `auto`：

- width : 默认就是 `auto`
- margin-left
- margin-right

如果某个值为 `auto`，则会自动调整 auto那个值使等式成立。

- 如果将一个宽度和一个外边据为 auto，那么宽度为调整为最大，外边距为 0
- 如果三个值设置为 auto，那么宽度为调整为最大，外边距为 0
- 如果两个外边据为 auto，宽度设置为固定值，那么两个外边距为调整为相等
  - 可以利用这个特性来设定水平居中

#### 盒子垂直方向布局

默认情况下，父元素的高度被内容撑开

子元素是在父元素的内容区排列的，如果子元素大小超过了父
元素，则子元素会溢出。

可以使用 `overflow` 来处理这种情况

- visible: 默认值，子元素会从父元素溢出
- hidden ：溢出内容将会被裁剪
- scroll : 生成两个滚动条，通过滚动条来查看完整内容
- auto ： 根据需要生成滚动条

#### 行内元素的盒子模型

- 行内元素的`width` 和 `height` 不支持手动设置
- 行内元素可以设置 `padding`,但垂直方向的 `padding` 不会影响页面布局
- 行内元素可以设置 `border`,但垂直方向的 `border` 不会影响页面布局
- 行内元素可以设置 `margin`,但垂直方向的 `margin` 不会影响页面布局

可以使用`display` 指定  
`display`:

- `inline`: 设置为行内元素
- `block`: 设置为块元素
- `inline-block`: 设置为行内块元素（可以设置宽高，又不独占一行）
- `table`: 设置为表格
- `none`: 元素不在页面显示

> 可以使用 `visibility` 设置元素显示状态

- `visible`,默认值
- `hidden`,隐藏但占位

#### 默认样式

> 通常情况下，浏览器会添加默认样式，默认样式的存在会影响页面的布局，通常在编写
> 网页时不需要去除默认样式

```css
list-style: none;
//去除列表前的点
```

```css
*{
        margin: 0;
        padding: 0;
}
```

#### 盒子 `box-sizing`

用來計算盒子尺寸的計算方式

- `content-sizing` 默认值
- `border-box` 边框不影响盒子可见宽大小

#### `outline`

用来设置元素的轮廓，类似于 `border`,但不会影响页面布局

#### `box-shadow` 阴影

用来设置元素的阴影效果，不会影响页面布局

```css
 box-shadow: 10px 10px 10px  green;
```

第一个值代表水平偏移，第二个代表垂直偏移，第三个值可以设置模糊半径，可设置负值

```css
box-shadow: 10px 10px rgba(0,0,0,.4);
```

#### 圆角

`border-radius`
`border-top-left-radius`
`border-top-right-radius`
`border-bottom-left-radius`
`border-bottom-right-radius`

```css
border-radius:10px;
...
border-top-left-radius: 10px 20px;
```

```css
border-radius:  50px 40px 40px 40px;
```

`border-radius` 可以指定4个角的圆角

- 4个值：左上 右上 右下 左下
- 3个值：左上 右上/左下 右下
- 2个值：左上/右下 右上/左下

 ```css
border-radius:50%
 ```

 可以设置为圆形

## 浮动

通过浮动可以设置一个元素向其父元素的左侧或者右侧

**注意：** 元素设置浮动后，水平布局的等式便不需要强制成立

- `left` 向左浮动
- `right` 向右浮动

元素设置浮动后 ，元素会完全从文档流中脱离，不在占据文档流的位置，元素下方的元素会补上

**特点**：

- 浮动会完全脱离文档流，不再占用文档流的位置
- 设置浮动后，元素会向父元素的左侧后右侧移动
- 浮动元素默认不会从父元素中移出
- 浮动元素不会盖过它前面的浮动元素
- 如果浮动元素的上边是一个没有浮动的块元素，则浮动无法上移动
- 浮动元素不会超过上边的兄弟元素，最多和兄弟元素一样高
- 浮动元素不会盖住文字，可以利用浮动实现文字环绕效果
- 元素设置浮动后，从文档流脱离，元素的一些特定也会发生一些变化

通过浮动可以制作一些水平方向的布局

### `clear`

如果我们不希望某个元素因为其他元素浮动的影响而改变位置，
可以使用clear 属性来清除浮动元素对当前元素的影响

- left ： 清除左侧
- right ： 清除右侧
- both :清除两侧最大影响的
原理：
清除浮动后浏览器会自动添加上外边距以使其不受影响

### 解决高度塌陷和外边距重叠

这个样式可以解决高度塌陷和外边距重叠的问题

```css
.clear-fix::before,
.clear-fix::after{
    content: '';
    display: table;
    clear: both;
}
```

### 定位 `position`

- 是一个更加高级的布局手段
- 可以将元素摆放到任意位置

可选值：

- static : 默认值，没开启定位.
- relative: 开启相对定位
- absolute:开启元素的绝对定位
- fixed: 开启元素的固定定位
- sticky : 开启元素的粘滞定位

**偏移量** `offset`

- 当元素开启定位后可以通过偏移量来设置元素位置
  - top: 定位元素上边和定位位置上边的距离
  - bottom： 定位元素下边和定位位置下边的距离
  - left: 定位元素左边和定位位置左边的距离
  - right: 定位元素右边和定位位置右边的距离
- 定位元素垂直方向由 `top` 和 `bottom`  来控制，top 越大，
元素越往下移动；bottom 越大， 元素越往上移动
- 定位元素水平方向由 `left` 和 `right`  来控制，left 越大，
元素越往右移动；right 越大， 元素越往左移动

#### 相对定位

指定 `position: relative;` 则开启了相对定位

**相对定位的特点**：

- 元素开启相对定位如果不设置偏移量元素不会发生任何的变化
- 相对定位参照于元素在文档流中的位置进行定位的
- 相对定位会提升元素的层级
- 相对定位不会脱离文档流
- 相对定位不会改变元素的性质 （块元素还是块元素）

#### 绝对定位

指定 `position: absolute;` 则开启了绝对定位

**绝对定位的特点**：

- 如果不指定偏移量那元素的位置则不会发生变化
- 开启绝对定位后，元素会从文档流中脱离
- 绝对定位会改变元素性质，行内元素会变成块，宽高被内容撑开
- 绝对定位会使元素提升一个层级
- 绝对定位是相对于其包含块来决定的
- [包含块](#包含块)

#### 固定定位

指定 `position: fixed;` 则开启了固定定位

- 大部分特点与[绝对定位](#绝对定位)类似
- 唯一不同的是固定定位永远参考浏览器窗口
- 固定定位不受网页滚动条影响

#### 粘滞定位

指定 `position: sticky;` 则开启了粘滞定位

- 大部分特点与[相对定位](#相对定位)类似
- 粘滞定位可以在元素达到某个位置时固定

#### 实际使用

主要还是学习[绝对定位](#绝对定位)

**注意**：`top`、`bottom`、`left`、`right` 默认为 `auto`

此处可参考[盒子垂直方向布局](#盒子垂直方向布局) 和 [盒子水平方向布局](#盒子水平方向布局)

如果9个值中没有 `auto` 则自动调整 `right` 或者 `bottom` 以使等式满足，如果有 auto 则自动调整 `auto` 数值

垂直方向也要求强制满足计算等式 （可以实现垂直居中）

### 元素的层级 `z-index`

对于开启了定位的元素，可以通过 `z-index` 属性来指定元素的层级关系，`z-index` 需要一个整数作为参数，值越大，元素层级越高，就越优先显示。

如果元素的层级一样，则优先显示靠下的元素

祖先元素无法盖住后代元素

## 字体

### `color`

设置字体的前景色

### `font-size`

设置字体大小

单位：

- `em`: 相对于当前元素的一个 font-size
- `rem`: 相对于根元素的一个 font-size

### `font-family`

指定字体格式

```css
p {
  font-family: '微软雅黑UI', Courier, monospace;
}
```

默认可选值(指定的字体分类)：

浏览器会自动使用该类别的字体内容

- `serif`: 衬线字体
- `sans-serif`: 非衬线字体
- `monospace`: 等宽字体
- `cursive`: 书法字体

可以指定多个字体，用`,`隔开

可以通过如下方式指定自定义字体

```css
@font-face {
  font-family: test-font;
 /* 指定字体名字 */
  src: url("./fonts/test.ttf");
}

@font-face {
  font-family: test-font2;
 /* 指定字体名字 */
  src: url("./fonts/test.ttf").format("truetype"),url("./fonts/test.woff").format("woff");
}
```

**注意**：

- 自定义字体加载速度较慢
- 字体的版权问题
- 字体格式的问题

### 图标字体 (icon-font)

在网页中经常需要使用一些图标，可以通过图片来引入，但图片本身本身较大，不太灵活，在使用图标时，可以直接设置成字体，然后就可以通过设置字体的方式来设置图标。

[fontawesome](https://fontawesome.com/)

使用方法：

- 复制 `css` 和 `webfonts` 文件夹到
- 引入 `CSS` 文件
- 使用 `CLASS` 指定

```css
<i class="fas fa-bahai"></i>
```

可以使用类来使用：

```css
li::before {
  content: '\f666';
  font-family: 'Font Awesome 5 Free';
  font-weight: 900;
}
```

可以通过实体来使用 (要指定类)

```html
<i class="fas">&#xf0f3;</i>
```

### 行高 (line height)

行高表示文字占用的实际高度，可以通过 `line-height` 来设置高度，单位为 (px 、em ) ... , 也可以指定一个整数。

如果是一个整数的话， 那么行高将会是字体的指定的倍数

默认的行高可能为 `1.33`

**字体框**：

字体框就是字体存在的格子，设置 `font-size`实际上就是在设置字体框的高度。

**行高会在字体框的上下平均分配** 。

- 可以将行高（`line-height`）设置为和高度（`height`）一样，可以使单行文字垂直居中

- 可以用于行间距的设置

### 字体的样式 `font-weight`

可以控制字体的加粗

`font-weight: normal;`

可选值：

- `normal` 没有变化
- `bold` 加粗

### 简写 `font`

语法：

```css
font: 50px "宋体";
font: bold 50px "宋体";
font: <font-weight> <字体大小: 必须最后>/<行高: 可选> <字体名称: 必须最后>;
font: 50px/2;
font: 50px/2 "宋体";
/* 可以多加一个行高，行高带有默认数值 */
```

注意，简写不写不代表不存在，默认的会覆盖掉以前设置的

### 文本的其他样式

#### 文字的水平对齐 `text-align`

- `left` 左对齐
- `right` 右对齐
- `center` 居中
- `justify` 两端对齐

#### 文字的垂直对齐 `vertical-align`

- `baseline` 基线对齐 [默认值]
- `top` 顶部对齐
- `bottom` 底部对齐
- `middle` 居中对齐

#### 设置文本修饰`text-decoration`

- `none` 什么都没有
- `underline` 下划线

在后面加上颜色值可以设置修饰的颜色和样式 （IE 不支持）

 ```css
text-decoration: underline red solid
 ```

#### 设置网页如何处理空白 `white-space`

- `normal`  默认值
- `nowrap` 不换行
- `pre` 保留文本格式

#### 设置文字裁剪后显示的内容 `text-overflow`

- `ellipsis` 省略号

```css
white-space: nowrap;
overflow: hidden;
width: 200px;
text-overflow: ellipsis;
```

## 背景

- 背景颜色 `background-color`
  - `background-color:#bfa`
- 背景图片 `background-image`
  - `background-image: url('./img/bg.jpg')`
  - 如果背景图片小于元素则图片会平铺将元素铺满
  - 如果背景图片大于元素将会有一部分无法显示
- 设置背景的重复方式 `background-repeat`
  - `repeat` [default] 沿着X轴和Y轴重复
  - `repeat-y` 沿着Y轴重复
  - `repeat-x` 沿着X轴重复
  - `no-repeat` 不重复
- 设置图片的位置`background-position`
  - `background-position:top left;`
  - `background-position:top right;`
  - `background-position:top center;`
  - 使用方位值时必须使用两个，否则第二个默认为 `center`
  - `background-position: 10px 10px` (可以为负数)
- 设置背景范围`background-clip`
  - `border-box` 背景在边框下方
  - `padding-box` 背景不会出现在边框，只会出现在内容区和内边距
  - `content-box` 只会出现在内容区
- 背景图片计算的原点（左上角） `background-origin`
  - `padding-box` 背景图片的偏移量从内边距来计算
  - `content-box` 背景图片的偏移量从内容处开始计算
  - `border-box` 背景图片的偏移量从边框处开始计算
- 设置背景图片的大小 `background-size`
  - `background-size: 100px 100px`
  - `background-size: 100px`
  - `background-size: auto 100%`
  - `cover` 图片比例不变，将元素铺满
  - `contain` 图片比例不变，将图片在元素中完整显示
- 背景图片是否跟随滚动 `background-attachment`
  - `scroll` 背景图片跟随滚动
  - `fixed` 背景图片不会滚动
- 简写 `background`
  - 所有背景的选项都可以在该样式设置，并且没有顺序选项
  - `background-size` 必须写在 `background-position` 的后面，并且使用斜杠隔开
  - `background-origin` 必须在 `background-clip` 的前面

可以设置背景颜色和背景图片，背景颜色会成为图片的背景色

### 雪碧图

网页图片按需加载，可能会出现图片替换时出现闪烁的问题，可以把多个图片放在一张图上，然后指定偏移量

## 颜色渐变

通过渐变可以设置一些复杂的背景色，实现一些颜色的像其他颜色过渡的效果，通过 `background-image` 来设置，类似于背景颜色

### 线性渐变

- 在渐变的开头，可以指定渐变的方向
  - `deg` ，表示度数
  - `turn`,表示圈数
  - 可以为方向
  - 线性渐变可以设置多个颜色，默认平均分配，也可以手动指定分配情况

```css
background-image: linear-gradient(red, yellow);
/*这表示红色开头，黄色结尾，从上往下*/
background-image: linear-gradient(to right, red, yellow);
/*这表示红色开头，黄色结尾，从左往右*/
background-image: linear-gradient(210deg, red, yellow)
/*可以通过度数来设置*/
background-image: linear-gradient(0.2turn, red, yellow)
/*可以通过圈数来设置*/
background-image: linear-gradient( red, yellow, green, orange);
/**可以指定多个颜色*/
background-image: linear-gradient(red 50px, yellow 100px);
/**可以指定多个颜色的分配情况*/
background-image: repeating-linear-gradient(red 50px, yellow 100px);
/**可以平铺的线性渐变（达到重复的效果）*/

```

### 径向渐变 （中心放射）

从中心向四周放射

- 默认情况下，径向渐变的形状是根据元素的形状来计算的
  - 正方形 --> 圆形
  - 长方形 --> 椭圆
- `radial-gradient(大小 at 位置,颜色 位置，颜色 位置 ...)`
  - 大小
    - circle 圆形
    - ellipse 椭圆
    - closest-side 近边
    - closest-corner 近角
    - farthest-side 远边
    - farthest-corner 远角

```css
background-image: radial-gradient(red, yellow)
/*设置径向渐变*/
background-image: radial-gradient(100px 100px, red, yellow);
/*设置径向渐变的大小*/
background-image: radial-gradient(circle, red, yellow);
/*设置为正圆*/
background-image: radial-gradient(ellipse, red, yellow);
/*设置为椭圆*/
background-image: radial-gradient(100px 100px at 0 0, red, yellow)
background-image: radial-gradient(at top left, red, yellow);
/* 设置渐变的位置 */
background-image: radial-gradient(closest-side at 50px 50px, red, yellow);
background-image: radial-gradient(farthest-side at 50px 50px, red, yellow);
/* 设置渐变靠近的位置 */
```

## 表格

```css
table {
  width: 50%;
  margin: 0 auto;
  text-align: center;
  border: 1px solid black;
  border-spacing: 0px;
  /* 指定边框之间的距离 */
  border-collapse: collapse;
  /* 设置边框的合并 */
}
```

注意：如果表格没有使用 `tbody` 而是直接使用 `tr`,浏览器会自动加上`tbody`

- 默认情况下元素在 `td` 下是垂直居中的,可以通过 `vertical-align` 来设置
  - 可以通过使用 `display:table-cell` 指定元素然后设置`vertical-align: middle` 来垂直居中

## 扩展

### `!important`

**慎用！！！**

可以某个样式后添加 `!important` ,此时该样式将获得最高优先级，甚至超过内联样式

```css
div{
    background-color: firebrick !important;
}
```

### 脱离文档流

- 块元素不再独占一行
- 块元素的宽度和高度默认被内容撑开
- 行内元素脱离文档流后就变成块元素，特性和块元素一样

脱离文档流后就不区分块元素和行内元素了

### 高度塌陷问题

父元素高度写死，内容过少会出现空白，内容过多导致内容溢出

在浮动布局中，父元素的高度默认是由子元素撑开的，当子元素浮动后，会从父元素脱离，将
无法撑起父元素，导致父元素高度丢失,父元素高度丢失后会导致其下的元素上移

将父元素高度写死可解决，但未完全解决

### BFC（block formatting context）块级格式化环境

- BFC 是一个隐含的属性，开启bfc后该元素会变成一个独立的布局区域
- 元素开启BFC 的特点：
  - 开启BFC的元素不会被浮动的元素覆盖
  - 开启BFC的元素和父元素的外边距不会和父元素外边距重叠
  - 开启BFC的元素可以包含浮动的子元素
- 可以通过特殊方式开启元素的`bfc `
  - 设置浮动
  - 设置元素为行内块元素
  - 将元素 `overflow` 设置为非 `visible` 的值
    - 【常用】 为元素设置 `overflow:hidden` 开启元素的bfc
  
### 包含块

- 正常情况下，包含块是当前元素最近的祖先**块元素**
- 绝对定位下，包含块就是离他最近的开启了定位的祖先元素
  - 如果所有的祖先元素都没有开启定位，则根元素是他的包含块

### 图片

图片上下对齐的问题可以通过 `vertical-align` 来设置