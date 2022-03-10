# MySQL 速览

## MySQL 语法


### 建立库、表

#### 创建库

```mysql
create database <tab_name>;
```

#### 创建表

语法：

```mysql
create table [if not exists] table_name(
    column_1_definition,
    column_2_definition,
    ...,
    table_constraints
) engine=storage_engine; # 数据库引擎
```

例如：

```mysql
create table projects(
    project_id int auto_increment,
    project_name varchar(255) not null,
    begin_date date,
    end_date date,
    cost decimal(15,2) not null,
    created_at timestamp default current_timestamp,
    primary key(project_id)
)
```

### 插入数据

#### 简单插入

`insert` 允许你向表中插入新行。

语法：

```sql
insert into table_name(column_list)
values(value_list);
```

示例：

```sql
insert into contacts(first_name, last_name, phone)
values('John','Doe','(408)-934-2443');
```

你可以通过以下函数拿到插入ID

```sql
select last_insert_id();
```

你可以指定 `default` 占位符以使用默认值

```sql
insert into contacts(first_name, last_name, phone, contact_group)
values('Roberto','carlos','(408)-242-3845',default);
```

另一种插入方法：

语法如下：

```sql
insert into table_name
set column1 = value1,
    column2 = value2;
```

在此语法中，您不必按顺序排列列和值。

示例：

```sql
insert into contacts
set first_name = 'Jonathan',
    last_name = 'Van'; 
```

#### 插入多行语句

语法：

```sql
insert into
    table_name(column_list)
values
    (value_list_1),
    (value_list_2),
    (value_list_3),
    ...;
```

示例：

```sql
insert into contacts(first_name, last_name, phone, contact_group)
values
    ('James','Smith','(408)-232-2352','Customers'),
    ('Michael','Smith','(408)-232-6343','Customers'),
    ('Maria','Garcia','(408)-232-3434','Customers');
```

#### 插入查询结果

语法：

```sql
insert into table_name(column_list)
select select_list
from table_name
...;
```

示例：

```sql
insert into small_countries
    (country_id, name, area)
select country_id,
       name,
       area
from countries
where area < 50000;

# 插入面积小于 50,000 平方公里的国家到small_countries表中.
```
### 更新数据


`update`语句允许您修改表中一列或多列的数据。

语法：

```sql
update table_name
set column1 = value1,
    column2 = value2,
    ...
[where search_condition];
```

示例：

```sql
update contacts
set last_name = 'Smith'
where id = 1;
#  将ID为1的行的姓氏更改为的语句 'Smith'
```

不带 `where` 条件可更新所有数据

```sql
update
    contacts
set phone = replace(phone, '-', ' ')
```

### 删除数据 

语法：

```sql
delete from table_name
[where search_condition];
```

删除一行：

```sql
delete from contacts
where id = 1;
```

删除全部：

```sql
delete from contacts;
```

### 检索数据-数据排序

使用 `order by`进行排序

语法如下

```sql
select 
    select_list
from 
    table_name
order by
    sort_expression1 [asc | desc],
    sort_expression2 [asc | desc],
    ...;  
```

### 检索数据-数据过滤

语法如下：

```sql
select
    select_list
from
    table_name
where
    search_condition
order by
    sort_expression;
```

```一个简单的例子如下
select name,area,region_id
from countries where region_id =2 order by name ;

# 查询地区编号为2的国家并按照名称升序排序
```

也可以用各种运算符

```sql
select name,area,region_id
from countries where area > 2000000 order by area desc ;

# 查询地区面积大于二百万的国家并按照面积从大到小排序
```

也可以组合多个条件

```sql
select
    name,
    area,
    region_id
from
    countries
where
        region_id = 2 or
        area > 2000000
order by
    area desc ;
# 查询地区面积大于二百万的国家和region的id为2并按照面积从大到小排序
```

也可查询某一范围值

```sql
select
    name,
    area
from
    countries
where
    area between 1001449
        and 10255200
order by
    area;

# 查询面积在 1001449 到 1566500 (包括 1566500)之间的国家
```

可以通过子查询查找某一范围

```sql
select name,
       country_code2
from countries
where country_code2 in ('US', 'FR', 'JP')
order by name;

# 查询国家中代号为 'US' 'FR' 'JP' 的国家
```

### 检索数据-通配符、正则表达式、函数 

#####  通配符模糊查询 `like`

###### 百分号(%)通配符
最常使用的通配符是百分号( `%` ) 。在搜索串中, `%`表示任何字符出现
任意次数。

**注意**：除了一个或多个字符外, %还能匹配0个字符。 %代表搜索模式中给定位置的0个、1个或多个字符。

例如,为了找出所有以词 ` J `起头的国家,可使用以下SELECT
语句:

```sql
select name
from countries
where name like 'J%'
order by name;

# 查询名称以 J 开头的国家
```

**注意**：根据MySQL的配置方式,搜索可以是区分大小写的。

###### 下划线通配符 `_`

下划线的用途与% 一样,但下划线只匹配单个字符而不是多个字符。

```mysql
select name
from countries
where name like '%A_'
order by name;

# 查询倒数第二个字母为 A 的国家
```

#### 正则表达式  `regexp`

MySQL 仅支持多数正则表达式实现的一个很小的子集。

##### 基本字符匹配

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '100';
# 匹配名字带 100 的用户
```
或者：

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '.00'; 
# 匹配包含整百的名字，如100,200,300等等
```

##### 进行OR匹配

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '100|200';
# 匹配名字包含 100 或 200 的用户 
```

使用or查询的情况，有点儿类似于`SELECT`中使用`OR`条件连接的情况，你可以把它们想象成并入了一个正则表达式。

##### 匹配几个字符之一

正则匹配中有一种特殊的`OR`匹配。

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '[12]';
```

上面表达式中我们使用了一个特殊的字符串`[12]`，这个字符串的含义是：查询名字中包含有数字1或者数字2的记录，它是`[1|2]`的缩写。

字符串还可以查询被否定的情况。例如：

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '[^12]';
```

`[^12]`如果在12之前加上一个`^`符号，那么就代表除了1或2外的字符串。

##### 匹配范围

集合可用来定义要匹配的一个或多个字符。例如, `[0123456789]`将匹配数字0到9，可简化成 `[0-9]`。

例如：

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '[0-9]';
```

这里的范围不仅仅只能是数字，还可以是字母。比如`[a-z]`就是表示从字母a到字母z的所有数字，26个字母。小写完了，还有大写`[A-Z]`。那么我们将其组合起来`[0-9a-zA-Z]`这个表达式就十分强大了，可以表示包含数字，小写字母，大写字母的所有记录。

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '[0-9a-zA-Z]';
```

##### 匹配特殊字符

正则表达式语言由具有特定含义的特殊字符构成。为了匹配特殊字符,必须用`\\`为前导。` \\-`表示查找`-`,` \\.`表示查找`.`。

```mysql
SELECT * FROM `tablle` WHERE `name` REGEXP '\\[ '; #匹配左方括号
SELECT * FROM `tablle` WHERE `name` REGEXP '\\. '; #匹配点号
SELECT * FROM `tablle` WHERE `name` REGEXP '\\] '; #匹配右方括号
SELECT * FROM `tablle` WHERE `name` REGEXP '\\| '; #匹配竖线
SELECT * FROM `tablle` WHERE `name` REGEXP '\\\ '; #匹配反斜杠自己本身
```

例如：

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '\\.12';
# 查询名字包含 .12 的用户
```
双反斜杠加上一些字母还可以表示特殊的含义。例如：

```mysql
SELECT * FROM `table` WHERE `name` REGEXP '\\f'; # 换页
SELECT * FROM `table` WHERE `name` REGEXP '\\n'; # 换行
SELECT * FROM `table` WHERE `name` REGEXP '\\r'; # 回车
SELECT * FROM `table` WHERE `name` REGEXP '\\t'; # 制表符
SELECT * FROM `table` WHERE `name` REGEXP '\\v'; # 纵向制表符
```

**扩展：**在一般的编程语言中，转义一般使用一个反斜线，在Mysql中为什么是两个才行？原因是：Mysql自己需要一个来识别，然后Mysql会将扣除了一个反斜杠的剩余的部分完全的交给正则表达式库解释，所以加起来就是两个了。

##### 匹配字符类

虽然正则表达式提供了一些很长表示方式的缩写，比如`[0-9]`表示数字。`[a-z]`表示小写字母。但是，有些时候还是觉得复杂。所以，正则表达式还提供了一些预定义的字符类来方便我们开发。

|      类      |                      说明                      |
| :----------: | :--------------------------------------------: |
| `[:alnum:]`  |      任意数字和字母。相当于`[a-zA-Z0-9]`       |
| `[:alpha:]`  |           任意字符。相当于`[a-zA-z]`           |
| `[:blank:]`  |           空格和制表。相当于`[\\t]`            |
| `[:cntrl:]`  |       ASCII控制字符（ASCII 0 到31和127）       |
| `[:digit:]`  |            任意数字。相当于`[0-9]`             |
| `[:graph:]`  |       与`[:print:]`相同，但是不包含空格        |
| `[:lower:]`  |         任意的小写字母。相当于`[a-z]`          |
| `[:print:]`  |                 任意可打印字符                 |
| `[:punct:]`  | 既不在`[:alnum:]`又不在`[:cntrl:]`中的任意字符 |
| `[:space:]`  |          包括空格在内的任意空白字符。          |
| `[:upper:]`  |          任意大写字母。相当于`[A-Z]`           |
| `[:xdigit:]` |    任意十六进制的数字。相当于`[a-fA-F0-9]`     |

##### 匹配多个实例

之前匹配的内容都是单词匹配。就是如果匹配到一次就显示，匹配不到就不显示。但是，复杂的情况有时候要求匹配不止一次。假设我需要匹配名字中包含2-3位数字的记录。这个时候就需要使用一种特殊的元字符来修饰。例如：

```mysql
SELECT * FROM `user` WHERE `name` REGEXP '[0-9]{2,3}';
```

特殊字符串`[0-9]{2,3}`，除去前面的`[0-9]`，后面的`{2,3}`就被成为重复元字符，它的作用就是使得前面的数字重复一定的次数。

| 元字符  | 作用                         |
| :-----: | ---------------------------- |
|   `*`   | 重复0次或者多次              |
|   `+`   | 重复一次或者多次。相当于{1,} |
|   `?`   | 重复0次或者1次               |
|  `{n}`  | 重复n次                      |
| `{n,}`  | 重复至少n次                  |
| `{n,m}` | 重复n-m次                    |

例如：

```mysql
SELECT * FROM user WHERE `name` REGEXP '[0-9]*'; 
# 匹配名字包含或者不包含数字的记录
```

或者：

```mysql
SELECT * FROM user WHERE `name` REGEXP '[0-9]{2,3}'; 
# 匹配名字内包含2位数或者3位数的记录
```

##### 定位符

除了之前的[重复元字符](#匹配多个实例)，正则还有一种特殊的[定位元字符](#定位符)。

|  元字符   |   作用   |
| :-------: | :------: |
|    `^`    | 文本开始 |
|    `$`    | 文本结尾 |
| `[[:<:]]` | 词的开始 |
| `[[:>:]]` | 词的结尾 |

例如：

```mysql
SELECT * FROM user WHERE `name` REGEXP '^[0-9]{11}$';
# 从头开始匹配到结尾，是11位数字
```

#### 函数

#### 聚合函数

聚合函数是平时比较常用的一类函数，这里列举如下：

- `COUNT(col)`  统计查询结果的行数
- `MIN(col)`  查询指定列的最小值
- `MAX(col)`  查询指定列的最大值
- `SUM(col)`  求和，返回指定列的总和
- `AVG(col)`  求平均值，返回指定列数据的平均值

#### 数值型函数

数值型函数主要是对数值型数据进行处理，得到我们想要的结果。

- `ABS(x)`  返回x的绝对值
- `BIN(x)`  返回x的二进制
- `CEILING(x)`  返回大于x的最小整数值
- `EXP(x)`  返回值e（自然对数的底）的x次方
- `FLOOR(x)`  返回小于x的最大整数值
- `GREATEST(x1,x2,...,xn)`  返回集合中最大的值
- `LEAST(x1,x2,...,xn)`  返回集合中最小的值
- `LN(x)`  返回x的自然对数
- `LOG(x,y)`  返回x的以y为底的对数
- `MOD(x,y)`  返回x/y的模（余数）
- `PI()`  返回pi的值（圆周率）
- `RAND()`  返回０到１内的随机值,可以通过提供一个参数(种子)使RAND()随机数生成器生成一个指定的值
- `ROUND(x,y)`  返回参数x的四舍五入的有y位小数的值
- `TRUNCATE(x,y)`  返回数字x截短为y位小数的结果

#### 字符串函数

字符串函数可以对字符串类型数据进行处理。

- `LENGTH(s)`  计算字符串长度函数，返回字符串的字节长度
- `CONCAT(s1,s2...,sn)`  合并字符串函数，返回结果为连接参数产生的字符串，参数可以是一个或多个
- `INSERT(str,x,y,instr)`  将字符串str从第x位置开始，y个字符长的子串替换为字符串instr，返回结果
- `LOWER(str)`  将字符串中的字母转换为小写
- `UPPER(str)`  将字符串中的字母转换为大写
- `LEFT(str,x)`  返回字符串str中最左边的x个字符
- `RIGHT(str,x)`  返回字符串str中最右边的x个字符
- `TRIM(str)`  删除字符串左右两侧的空格
- `REPLACE`  字符串替换函数，返回替换后的新字符串
- `SUBSTRING`  截取字符串，返回从指定位置开始的指定长度的字符换
- `REVERSE(str)`  返回颠倒字符串str的结果

#### 日期和时间函数

`CURDATE` 和 `CURRENT_DATE`  两个函数作用相同，返回当前系统的日期值

`CURTIME` 和 `CURRENT_TIME`  两个函数作用相同，返回当前系统的时间值

`NOW` 和 `SYSDATE`  两个函数作用相同，返回当前系统的日期和时间值

`UNIX_TIMESTAMP`  获取**UNIX时间戳**函数，返回一个以**UNIX 时间戳为基础的无符号整数**

`FROM_UNIXTIME`  将 **UNIX 时间戳**转换为**时间格式**，与`UNIX_TIMESTAMP`互为反函数

`MONTH`  获取指定日期中的月份

`MONTHNAME`  获取指定日期中的月份英文名称

`DAYNAME`  获取指定曰期对应的星期几的英文名称

`DAYOFWEEK`  获取指定日期对应的一周的索引位置值

`WEEK`  获取指定日期是一年中的第几周，返回值的范围是否为 0〜52 或 1〜53

`DAYOFYEAR`  获取指定曰期是一年中的第几天，返回值范围是1~366

`DAYOFMONTH`  获取指定日期是一个月中是第几天，返回值范围是1~31

`YEAR`  获取年份，返回值范围是 1970〜2069

`TIME_TO_SEC`  将时间参数转换为秒数

`SEC_TO_TIME`  将秒数转换为时间，与TIME*TO*SEC 互为反函数

`DATE_ADD` 和 `ADDDATE`  两个函数功能相同，都是向日期添加指定的时间间隔

`DATE_SUB` 和 `SUBDATE`  两个函数功能相同，都是向日期减去指定的时间间隔

`ADDTIME`  时间加法运算，在原始时间上添加指定的时间

`SUBTIME`  时间减法运算，在原始时间上减去指定的时间

`DATEDIFF`  获取两个日期之间间隔，返回参数 1 减去参数 2 的值

`DATE_FORMAT`  格式化指定的日期，根据参数返回指定格式的值

`WEEKDAY`  获取指定日期在一周内的对应的工作日索引

### 检索数据-数据分组

`group by`用于将结果的行分组,语法如下：

```sql
select
    column1,
    aggregate_function(column2)
from
    table_name
group by
    column1;
```

group by通常与聚合函数一起使用，包括 `count()`, `min()`, `max()`, `sum()`， 和 `avg()` 等等

例如：

```sql
select region_id,
       count(country_id) count
from countries
group by region_id
order by region_id;

# 查询此地区下有多少个国家
```

#### 条件 `having`

`where` 子句允许您指定一个条件来过滤返回的`select`查询。 但是，它不能过滤 `group by`。

想过滤 group by，你需要使用 `having`

示例：

```sql
select regions.name      region,
       count(country_id) country_count
from countries
         inner join regions
                    using (region_id)
group by (regions.name)
having count(region_id) > 10
order by country_count desc;

#使用 having子句查找拥有超过 10 个国家/地区的地区 

```

### 子查询

子查询是嵌套在另一个查询中的查询。

#### 标量子查询

必须而且也只能返回一行一列的查询结果，返回是一个单一的值。返回的单一的值可以和比较运算符一起使用。在where子句中不能使用汇总函数。

```sql
select *
from countries
where area = (
    select max(area)
    from countries
);

#查找面积最大的国家/地区
```

#### 行子查询

行子查询返回单行。

```sql
select name
from country_stats
         inner join countries
                    using (country_id)
where year = 2018
  and (population, gdp) > (
    select avg(population) as a,
           avg(gdp)        as b
    from country_stats
    where year = 2018)
order by name;

```

#### FROM 下的子查询

你可以将子查询放在 FROM 后

```sql
select avg(region_area)
from (
         select sum(area) region_area
         from countries
         group by region_id
     ) t;
```

### 检索数据-相关子查询

相关子查询是一个子查询中引用了某张表且这张表也在子查询外部被使用到。

```mysql
SELECT * FROM t1
WHERE column1 IN (
    SELECT column1 FROM t2
    WHERE t2.column2 = t1.column2);
```

请注意子查询有一个`t1`表`column2`的引用，尽管子查询的`from`语句中没有涉及`t1`表，这时MySQL执行子查询却发现`t1`表在外部查询中。

相关子查询是使用外部查询中的值的子查询（嵌套在另一个查询中的查询）。因为子查询需为外部查询返回的每一行执行一次，所以它可能会很慢。

### 检索数据-不相关子查询

子查询是一个单独的`select`语句，可以不依赖主查询单独运行。这种不依靠主查询，能够独立运行的子查询称为**“非相关子查询”**。

### 检查数据-联表查询

#### 内连接 `inner join`

输出匹配规则的列（取交集）

```sql
select g.guest_id,
       g.name,
       v.vip_id,
       v.name
from guests g
         inner join vips v
                    on v.name = g.name;

# 输出guests 表下与vips下同名的列字段组合

```

#### 左连接 `left join`

`left join`以左表为基准，匹配右表字段，如果匹配成功，则 `left join`创建一个新行，其列包含由选择列表指定的两行的列。如果 `left join`在右表中没有找到任何匹配的行，它仍然创建一个新行，其列包含左表中的行的列和null

例如：

```sql
select g.guest_id,
       g.name,
       v.vip_id,
       v.name
from guests g
         left join vips v
                   using (name);

# 从guests表中检索他们是否有来自vips表的匹配行。如果没有则输出null

```

#### 右连接 `right join`

和 `left join` 类似，只不过以右表为基准

例如：

```sql
select g.guest_id,
       g.name,
       v.vip_id,
       v.name
from guests g
         right join vips v
                   using (name);
```

#### 笛卡尔积 `cross join`

对连接表中的行进行笛卡尔积处理。

```sql
select g.guest_id,
       g.name,
       v.vip_id,
       v.name
from guests g
         cross join vips v;

```

## B+树索引

### InnoDB 的索引方案之聚簇索引

B+ 树本身就是一个目录,或者说本身就是一个索引。它有两个特点:

1. 使用记录主键值的大小进行记录和页的排序,这包括三个方面的含义:
页内的记录是按照主键的大小顺序排成一个单向链表。各个存放用户记录的页也是根据页中用户记录的主键大小顺序排成一个双向链表。存放目录项记录的页分为不同的层次,在同一层次中的页也是根据页中目录项记录的主键大小顺序排成 一个双向链表。
2. B+ 树的叶子节点存储的是完整的用户记录。
所谓完整的用户记录,就是指这个记录中存储了所有列的值(包括隐藏列)。我们把具有这两种特性的 B+ 树称为 聚簇索引,所有完整的用户记录都存放在这个 聚簇索引 的叶子节点处。这种聚簇索引并不需要我们在 MySQL 语句中显式的使用 INDEX 语句去创建, InnoDB 存储引擎会自动的为我们创建聚簇索引。另外有趣的一点是,在 InnoDB 存储引擎中, 聚簇索引 就是数 据的存储方式(所有的用户记录都存储在了 叶子节点 ),也就是所谓的索引即数据,数据即索引。

使用innodb引擎时，每张表都有一个聚簇索引，比如我们设置的主键就是聚簇索引，聚簇是指数据的存储方式，表示数据行和相邻的键值紧凑的储存在一起
**特点**：查询数据特别快，因为聚簇索引和行数据存储在磁盘的同一页，这样可以减少磁盘I/O操作次数。
**注意**：主键应该尽量简短。

### InnoDB 的索引方案之二级索引

除了聚簇索引外的其他索引叫做二级索引（辅助索引），比如我们给除主键外其他字段创建的索引。

特点：二级索引里面存储了聚簇索引，最后要通过聚簇索引找到行数据。可见，聚簇索引的效率会影响其他索引。

### InnoDB 的索引方案之联合索引

组合索引也称为复合索引（联合索引），是指把多个字段组合起来创建一个索引（最多16个字段），遵循最左前缀匹配原则

扩展：**最左前缀匹配原则（leftmost prefix principle）**：MySQL 会从左向右匹配直到遇到不能使用索引的条件（`>`、`<`、`!=`、`not`、`like`模糊查询的`%`前缀）才停止匹配。

### 索引的语法(创建、删除、修改)

#### 创建索引

索引名称 `index_name` 是可以省略的,省略后,索引的名称和索引列名相同。

```mysql
-- 创建普通索引
CREATE INDEX index_name ON table_name(col_name);
-- 创建唯一索引
CREATE UNIQUE INDEX index_name ON table_name(col_name);
-- 创建普通组合索引
CREATE INDEX index_name ON table_name(col_name_1,col_name_2);
-- 创建唯一组合索引
CREATE UNIQUE INDEX index_name ON table_name(col_name_1,col_name_2);
```

##### 修改表结构创建索引

```mysql
 ALTER TABLE table_name ADD INDEX index_name(col_name);
```

##### 创建表时直接指定索引

```mysql
CREATE TABLE table_name (
ID INT NOT NULL,
col_name VARCHAR (16) NOT NULL,
INDEX index_name (col_name)
);
```

#### 删除索引

```mysql
-- 直接删除索引
DROP INDEX index_name ON table_name;
-- 修改表结构删除索引
ALTER TABLE table_name DROP INDEX index_name;
```

#### 其它相关命令

```mysql
-- 查看表结构
 desc table_name;
-- 查看生成表的SQL
show create table table_name;
-- 查看索引信息(包括索引结构等)
show index from
table_name;
 -- 查看SQL执行时间(精确到小数点后8位)
 set profiling = 1;
 SQL...
 show profiles;
```



#### 创建索引准则

##### 应该创建索引的列
- 在经常需要搜索的列上,可以加快搜索的速度。
- 在作为主键的列上,强制该列的唯一性和组织表中数据的排列结构。
- 在经常用在连接(JOIN)的列上,这些列主要是一外键,可以加快连接的速度。
- 在经常需要根据范围(<,<=,=,>,>=,BETWEEN,IN)进行搜索的列上创建索引,因为索引已经排序,其指定的范围是连续的。
- 在经常需要排序(order by)的列上创建索引,因为索引已经排序,这样查询可以利用索引的排序,加快排序查询时间。
- 在经常使用在WHERE子句中的列上面创建索引,加快条件的判断速度。

##### 不该创建索引的列

- 对于那些在查询中很少使用或者参考的列不应该创建索引。
- 若列很少使用到,因此有索引或者无索引,并不能提高查询速度。相反,由于增加了索引,反而降低了系统的维护速度和增大了空间需求。
- 对于那些只有很少数据值或者重复值多的列也不应该增加索引。
- 这些列的取值很少,例如人事表的性别列,在查询的结果中,结果集的数据行占了表中数据行的很大比例,即需要在表中搜索的数据行的比例很大。增加索引,并不能明显加快检索速度。
- 对于那些定义为text, image和bit数据类型的列不应该增加索引。这些列的数据量要么相当大,要么取值很少。
- 当该列修改性能要求远远高于检索性能时,不应该创建索引。(修改性能和检索性能是互相矛盾的)

### 索引的代价

#### 索引的优缺点

##### 优点

- 索引大大减小了服务器需要扫描的数据量,从而大大加快数据的检索速度,这也是创建索引的最主
  要的原因。
- 索引可以帮助服务器避免排序和创建临时表。
- 索引可以将随机IO变成顺序IO。
- 索引对于InnoDB(对索引支持行级锁)非常重要,因为它可以让查询锁更少的元组,提高了表访问并发性
- 关于InnoDB、索引和锁:InnoDB在二级索引上使用共享锁(读锁),但访问主键索引需要排他锁(写锁)。
- 通过创建唯一性索引,可以保证数据库表中每一行数据的唯一性。
- 可以加速表和表之间的连接,特别是在实现数据的参考完整性方面特别有意义。
- 在使用分组和排序子句进行数据检索时,同样可以显著减少查询中分组和排序的时间。
- 通过使用索引,可以在查询的过程中,使用优化隐藏器,提高系统的性能。

#####  缺点

- 创建索引和维护索引要耗费时间,这种时间随着数据量的增加而增加
- 索引需要占物理空间,除了数据表占用数据空间之外,每一个索引还要占用一定的物理空间,如果需要建立聚簇索引,那么需要占用的空间会更大。
- 对表中的数据进行增、删、改的时候,索引也要动态的维护,这就降低了整数的维护速度。
- 如果某个数据列包含许多重复的内容,为它建立索引就没有太大的实际效果。
- 对于非常小的表,大部分情况下简单的全表扫描更高效;

### 索引的扫描区间和边界条件

#### B+树索引适用的条件

```sql
CREATE TABLE person_info(
 id INT NOT NULL auto_increment,
 name VARCHAR(100) NOT NULL,
 birthday DATE NOT NULL,
 phone_number CHAR(11) NOT NULL,
 country varchar(100) NOT NULL,
 PRIMARY KEY (id),
 KEY idx_name_birthday_phone_number (name, birthday, phone_number)
);
```

- 先按照 name 列的值进行排序。 
- 如果 name 列的值相同，则按照 birthday 列的值进行排序。 
- 如果 birthday 列的值也相同，则按照 phone_number 的值进行排序。

这个排序方式**十分、特别、非常、巨、very very very重要**，因为只要页面和记录是排好序的，我们就可以通过二 分法来快速定位查找。

##### 全值匹配

如果我们的搜索条件中的列和索引列一致的话，这种情况就称为全值匹配，比方说下边这个查找语句：

```sql
SELECT * FROM person_info WHERE name = 'Ashburn' AND birthday = '1990-09-27' AND phone_number = '15123983239';
```

##### 匹配左边的列

其实在我们的搜索语句中也可以不用包含全部联合索引中的列，只包含左边的就行，比方说下边的查询语句：

```sql
SELECT * FROM person_info WHERE name = 'Ashburn';
```

或者包含多个左边的列也行： 

```sql
SELECT * FROM person_info WHERE name = 'Ashburn' AND birthday = '1990-09-27';
```

那为什么搜索条件中必须出现左边的列才可以使用到这个 B+ 树索引呢？比如下边的语句就用不到这个 B+ 树索引 么？

```sql
SELECT * FROM person_info WHERE birthday = '1990-09-27';
```

**如果我们想使用联合索引中尽可能多的列，搜索条件中的各个列必须是联合索引中 从最左边连续的列。**

##### 匹配列前缀

对于字符串类型的索引列来说，我们只匹配 它的前缀也是可以快速定位记录的，比方说我们想查询名字以 'As' 开头的记录，那就可以这么写查询语句：

```sql
SELECT * FROM person_info WHERE name LIKE 'As%';
```

但是需要注意的是，如果只给出后缀或者中间的某个字符串，比如这样：

```sql
SELECT * FROM person_info WHERE name LIKE '%As%';
```

MySQL 就无法快速定位记录位置了，因为字符串中间有 'As' 的字符串并没有排好序，所以只能全表扫描了。

有 时候我们有一些匹配某些字符串后缀的需求，比方说某个表有一个 url 列，该列中存储了许多URL：

- www.baidu.com 
- www.google.com 

假设已经对该 url 列创建了索引，如果我们想查询以 com 为后缀的网址的话可以这样写查询条件： `WHERE url LIKE '%com'` ，但是这样的话无法使用该 url 列的索引。为了在查询时用到这个索引而不至于全表扫描，我们可 以把后缀查询改写成前缀查询，不过我们就得把表中的数据全部逆序存储一下，也就是说我们可以这样保存 url 列中的数据：

- moc.udiab.www 
- moc.elgoog.www 

这样再查找以 com 为后缀的网址时搜索条件便可以这么写： `WHERE url LIKE 'moc%'` ，这样就可以用到索引了。

##### 匹配范围值

**所有记录都是按照索引列的值从小到大的顺序排好序的**，所以这极大的方便我们查找索引列的值在某个范围内的记录。比方说下边这个查询语句：

```sql
SELECT * FROM person_info WHERE name > 'Asa' AND name < 'Barlow';
```

- 找到 name 值为 Asa 的记录。
- 找到 name 值为 Barlow 的记录。
- **记录之间用单链表，数据页之间用双链表**
- 找到这些记录的主键值，再到 聚簇索引 中 回表 查找完整的记录。

如果对多个列同时进行范围查找的话，只有对索引**最左边**的那个 列进行范围查找的时候才能用到 B+ 树索引，比方说这样：

```sql
SELECT * FROM person_info WHERE name > 'Asa' AND name < 'Barlow' AND birthday > '1980-01-01';
```

通过 name 进行范围查 找的记录中可能并不是按照 birthday 列进行排序的

##### 精确匹配某一列并范围匹配另外一列

如果左边的列是精 确查找，则右边的列可以进行范围查找

```sql
SELECT * FROM person_info WHERE name = 'Ashburn' AND birthday > '1980-01-01' AND birthday< '2000-12-31' AND phone_number > '15100000000';
```

这个查询的条件可以分为3个部分：

- `name = 'Ashburn'` ，对 name 列进行精确查找，当然可以使用 B+ 树索引了
- `birthday > '1980-01-01' AND birthday < '2000-12-31'` ，由于 name 列是精确查找，所以通过 `name = 'Ashburn'` 条件查找后得到的结果的 name 值都是相同的，它们会再按照 `birthday` 的值进行排序。所以此时 对 `birthday` 列进行范围查找是可以用到 B+ 树索引的。
- `phone_number > '15100000000'` ，通过 `birthday` 的范围查找的记录的 `birthday` 的值可能不同，所以这个 条件无法再利用 B+ 树索引了，只能遍历上一步查询得到的记录。

##### 用于排序

在 MySQL 中，把这种在内存中或者磁 盘上进行排序的方式统称为**文件排序（File Sort ）**，跟 文件 这个词儿一沾边儿，就显得这些排序操作 非常慢了（磁盘和内存的速度比起来，就像是飞机和蜗牛的对比）。但是如果 `ORDER BY` 子句里使用到了我们的索引列，就有可能省去在内存或文件中排序的步骤，比如下边这个简单的查询语句：

```sql
SELECT * FROM person_info ORDER BY name, birthday, phone_number LIMIT 10;
```

#### 回表的代价

```sql
SELECT * FROM person_info WHERE name > 'Asa' AND name < 'Barlow';
```

而查询列表是 `*` ，意味着要查询表中所有字段，也就是还要包括 `country` 字段。这时需要把从上一步中获取到的每一条记录的 `id` 字段都**到聚簇索引对应的 B+ 树中找到完整的用户记录**，也就是我们通常所说的回表 ，然后把完整的用户记录返回给查询用户。

一般情况下，顺序I/O比随机I/O的性能高很多

- 会使用到两个 B+ 树索引，一个二级索引，一个聚簇索引。
-  访问二级索引使用 顺序I/O ，访问聚簇索引使用 随机I/O 。

**需要回表的记录越多，使用二级索引的性能就越低**

查询优化器：查询优化器会事先对表中的记录计算一些统计数据，然后再利用这些统计数据根据查询的 条件来计算一下需要回表的记录数，需要回表的记录数越多，就越倾向于使用全表扫描，反之倾向于使用 二级索引 + 回表 的方式。

因为回表的记录越少， 性能提升就越高，比方说上边的查询可以改写成这样：

```sql
SELECT * FROM person_info WHERE name > 'Asa' AND name < 'Barlow' LIMIT 10
```

添加了 LIMIT 10 的查询更容易让优化器采用 二级索引 + 回表 的方式进行查询。

#### 覆盖索引

为了彻底告别 回表 操作带来的性能损耗，我们建议：**最好在查询列表里只包含索引列**，比如这样：

```sql
SELECT name, birthday, phone_number FROM person_info WHERE name > 'Asa' AND name < 'Barlow'
```

不必到 聚簇索引 中再查找记录的剩余列，也就是 country 列的值了，这样就省去了 回表 操作带来的性能损耗。我们把这种只需要用到索引的查询方式称为 索引 覆盖 。排序操作也优先使用 覆盖索引 的方式进行查询，比方说这个查询：

```sql
SELECT name, birthday, phone_number FROM person_info ORDER BY name, birthday, phone_number;
```

#### 使用联合索引进行排序的注意事项

`ORDER BY` 的子句后边的列的顺序也必须按照索引列的顺序给出，如果给出 `ORDER BY phone_number, birthday, name` 的顺序，那也是用不了 B+ 树索引，而 `ORDER BY name` 、 `ORDER BY name, birthday` 这种匹配索引左边的列的形式可以使用部分的 B+ 树索引。

当联合索引左边列的值为常量，也可以使用后边的列进行排序，比如这样：

```sql
SELECT * FROM person_info WHERE name = 'A' ORDER BY birthday, phone_number LIMIT 10;
```

#### 不可以使用索引进行排序的几种情况

##### ASC、DESC混用

对于使用联合索引进行排序的场景，我们要求各个排序列的排序顺序是一致的，也就是要么各个列都是 ASC 规则 排序，要么都是 DESC 规则排序。

但是如果我们查询的需求是先按照 name 列进行升序排列，再按照 birthday 列进行降序排列的话，比如说这样的 查询语句：

```sql
SELECT * FROM person_info ORDER BY name, birthday DESC LIMIT 10;
```

##### WHERE子句中出现非排序使用到的索引列

如果WHERE子句中出现了非排序使用到的索引列，那么排序依然是使用不到索引的，比方说这样：

```sql
SELECT * FROM person_info WHERE country = 'China' ORDER BY name LIMIT 10;
```

这个查询只能先把符合搜索条件 country = 'China' 的记录提取出来后再进行排序，是**使用不到索引**。注意和下 边这个查询作区别：

```sql
SELECT * FROM person_info WHERE name = 'A' ORDER BY birthday, phone_number LIMIT 10;
```

虽然这个查询也有搜索条件，但是 `name = 'A'` 可以使用到索引 `idx_name_birthday_phone_number` ，而且过滤剩 下的记录还是按照 `birthday` 、 `phone_number` 列排序的，所以还是**可以使用索引**进行排序的。

##### 排序列包含非同一个索引的列

有时候用来排序的多个列不是一个索引里的，这种情况也不能使用索引进行排序，比方说：

```sql
SELECT * FROM person_info ORDER BY name, country LIMIT 10;
```

`name` 和 `country` 并不属于一个联合索引中的列，所以无法使用索引进行排序

#### 排序列使用了复杂的表达式

要想使用索引进行排序操作，必须保证索引列是以单独列的形式出现，而不是修饰过的形式，比方说这样：

```sql
SELECT * FROM person_info ORDER BY UPPER(name) LIMIT 10;
```

使用了 UPPER 函数修饰过的列就不是单独的列啦，这样就无法使用索引进行排序啦。

### 用于分组

有时候我们为了方便统计表中的一些信息，会把表中的记录按照某些列进行分组。比如下边这个分组查询：

```sql
SELECT name, birthday, phone_number, COUNT(*) FROM person_info GROUP BY name, birthday, phone_number
```

### 总结

在使用索引时需要注意下边这些事项：

- 只为用于搜索、排序或分组的列创建索引 
- 为列的基数大的列创建索引 
- 索引列的类型尽量小 
- 可以只对字符串值的前缀建立索引 
- 只有索引列在比较表达式中单独出现才可以适用索引 
- 为了尽可能少的让 聚簇索引 发生页面分裂和记录移位的情况，建议让主键拥有 `AUTO_INCREMENT` 属性。 
- 定位并删除表中的重复和冗余索引 尽量使用 
- 覆盖索引 进行查询，避免 回表 带来的性能损耗。

## 优化与 EXPLAIN

### MySQL 如何做优化?

- 首先,MySQL(与所有DBMS一样)具有特定的硬件建议。在学习和研究MySQL时,使用任何旧的计算机作为服务器都可以。但对用于生产的服务器来说,应该坚持遵循这些硬件建议。
- 一般来说,关键的生产DBMS应该运行在自己的专用服务器上。
- MySQL是用一系列的默认设置预先配置的,从这些设置开始通常是很好的。但过一段时间后你可能需要调整内存分配、缓冲区大小等 。 为查看当前设置 , 可使用 `SHOW VARIABLES`; 和 `SHOW STATUS`;
- MySQL一个多用户多线程的DBMS,换言之,它经常同时执行多个任务。如果这些任务中的某一个执行缓慢,则所有请求都会执行缓慢。如果你遇到显著的性能不良,可使用`SHOW PROCESSLIST`显示所有活动进程以及它们的线程ID和执行时间 。你还可以用`KILL`命令终结某个特定的进程(使用这个命令需要作为管理员登录) 。
- 总是有不止一种方法编写同一条 `SELECT`语句。应该试验联结、并、子查询等,找出最佳的方法。
- 使用`EXPLAIN`语句让MySQL解释它将如何执行一条`SELECT` 语句。
- 一般来说,存储过程执行得比一条一条地执行其中的各条`MySQL`语句快。
- 应该总是使用正确的数据类型。
- 决不要检索比需求还要多的数据。换言之,不要用 `SELECT *` (除非你真正需要每个列) 。
- 有的操作(包括`INSERT`)支持一个可选的`DELAYED`关键字,如果使用它,将把控制立即返回给调用程序,并且一旦有可能就实际执行该操作。
- 在导入数据时,应该关闭自动提交。你可能还想删除索引(包括FULLTEXT索引) ,然后在导入完成后再重建它们。
- 必须索引数据库表以改善数据检索的性能。确定索引什么不是一件微不足道的任务,需要分析使用的 SELECT 语句以找出重复的`WHERE` 和`ORDER BY` 子句。如果一个简单的 WHERE子句返回结果所花的时间太长,则可以断定其中使用的列(或几个列)就是需要索引的对象。
- 你的 `SELECT` 语句中有一系列复杂的 `OR` 条件吗?通过使用多条`SELECT` 语句和连接它们的 `UNION` 语句,你能看到极大的性能改进。
- 索引改善数据检索的性能,但损害数据插入、删除和更新的性能。
- 如果你有一些表,它们收集数据且不经常被搜索,则在有必要之前不要索引它们。 (索引可根据需要添加和删除。 )
- LIKE 很慢。一般来说,最好是使用FULLTEXT而不是LIKE。
- 数据库是不断变化的实体。一组优化良好的表一会儿后可能就面目全非了。由于表的使用和内容的更改,理想的优化和配置也会改变。
- 最重要的规则就是,每条规则在某些条件下都会被打破。

### 结合 EXPLAIN 查看执行计划

EXPLAIN 查看 SQL 执行计划、分析索引的效率。

| 列名            | 描述                                                     |
| --------------- | -------------------------------------------------------- |
| `id`            | 在一个大的查询语句中每个`SELECT`关键字都对应一个唯一的id |
| `select_type`   | `SELECT`关键字对应的那个查询的类型                       |
| `table`         | 表名                                                     |
| `partitions`    | 匹配的分区信息                                           |
| `type`          | 针对单表的访问方法                                       |
| `possible_keys` | 可能用到的索引                                           |
| `key`           | 实际上使用的索引                                         |
| `key_len`       | 实际使用到的索引长度                                     |
| `ref`           | 当使用索引列等值查询时，与索引列进行等值匹配的对象信息   |
| `rows`          | 预估的需要读取的记录条数                                 |
| `filtered`      | 某个表经过搜索条件过滤后剩余记录条数的百分比             |
| `Extra`         | 一些额外的信息                                           |

详细参考：[MySQL执行计划Explain详解](https://juejin.cn/post/6850418111272009735)

## 事务 

### ACID 的概念

#### 概念

- 原子性（Atomicity）：要么全部完成，要么全部不完成；
- 一致性（Consistency）：一个事务单元需要提交之后才会被其他事务可见；
- 隔离性（Isolation）：并发事务之间不会互相影响，设立了不同程度的隔离级别，通过适度的破坏一致性，得以提高性能；
- 持久性（Durability）：事务提交后即持久化到磁盘不会丢失。

#### 解释

- 原子性（Atomicity）

  原子性是指一个事务是一个不可分割的工作单位，其中的操作要么都做，要么都不做；如果事务中一个sql语句执行失败，则已执行的语句也必须回滚，数据库退回到事务前的状态。

- 一致性（Consistency）

  一致性是指事务执行结束后，数据库的完整性约束没有被破坏，事务执行的前后都是合法的数据状态。数据库的完整性约束包括但不限于：实体完整性（如行的主键存在且唯一）、列完整性（如字段的类型、大小、长度要符合要求）、外键约束、用户自定义完整性（如转账前后，两个账户余额的和应该不变）。

- 隔离性（Isolation）

  与原子性、持久性侧重于研究事务本身不同，隔离性研究的是不同事务之间的相互影响。隔离性是指，事务内部的操作与其他事务是隔离的，并发执行的各个事务之间不能互相干扰。严格的隔离性，对应了事务隔离级别中的Serializable (可串行化)，但实际应用中出于性能方面的考虑很少会使用可串行化。

- 持久性（Durability）

  持久性是指事务一旦提交，它对数据库的改变就应该是永久性的。接下来的其他操作或故障不应该对其有任何影响。
  
  

### 开启事务

**注意：**并非所有引擎都支持事务处理。 `MyISAM`和`InnoDB`是两种最常使用的引擎。前者不支持明确的事务处理管理,而后者支持。这就是为什么本书中使用的样例表被创建来使用`InnoDB`而不是更经常使用的`MyISAM`的原因。如果你的应用中需要事务处理功能,则一定要使用正确的引擎类型。

语法：

```mysql
start transaction; # 开启事务
#一条或多条sql语句
commit;# 提交事务
```

### 提交事务

MySQL 事务使用 `commit` 提交事务。

### 手动中止事务

MySQL的 `ROLLBACK` 命令用来 **回退(撤销)** MySQL 语句。

### 自动提交

MySQL中默认采用的是**自动提交(autocommit)**模式，在自动提交模式下，如果没有`start transaction`显式地开始一个事务，那么每个 sql 语句都会被当做一个事务执行提交操作。

### 隐式提交 

MySQL 的提交方式分为三种：自动提交、显示提交、隐式提交。

隐式提交是在进行事务时执行特定的语句，导致像是使用 `commit` 提交命令一样使事务提前结束。

#### 隐式提交触发语句

1. 正常执行完**DDL**语句。包括`create`，`alter`，`drop`，`truncate`，`rename`。
1. 正常执行完**DCL**语句。包括`grant`，`revoke`。
1. 正常退出数据库管理软件，没有明确发出`commit`或者`rollback`。

除了基本的查询语句与增删改的对表的操纵语句外基本都是隐式提交的，使用时要注意。

### 保存点

简单的`ROLLBACK`和`COMMIT`语句就可以写入或撤销整个事务处理。但是,只是对简单的事务处理才能这样做,更复杂的事务处理可能需要部分提交或回退。

为了支持回退部分事务处理,必须能在事务处理块中合适的位置放置占位符。这样,如果需要回退,可以回退到某个占位符。

这些占位符称为保留点。为了创建占位符,可使用`SAVEPOINT`语句。每个保留点都取标识它的唯一名字,以便在回退时,MySQL知道要回退到何处。

保留点在事务处理完成(执行一条`ROLLBACK`或`COMMIT` )后自动释放。自 MySQL 5 以来,也可以用`RELEASE SAVEPOINT`明确地释放保留点。

例如：

```mysql
start transaction; # 开启事务
#一条或多条sql语句
savepoint <Name>; # 创建保留点 ,名称为 <Name>
#一条或多条sql语句
rollback to <Name>; # 回滚至名为 <Name> 的保留点
release savepoint <Name>; # 释放名为 <Name> 的保留点 
commit;# 提交事务
```

## 锁

### 并发事务带来的问题

####  脏读（dirty read）

没有提交的事务被其他事务读取到了，这叫做脏读 。

#### 不可重复读（unrepeatable read）

读取了另一个事务提交之后的修改。
不可重复读和脏读的区别在于，脏读是读取了另一个事务未提交的修改，而不可重复读是读取了另一个事务提交之后的修改，本质上都是其他事务的修改影响了本事务的读取。
不可重复读是因为其他事务进行了 `UPDATE` 操作。

**多次查询一行时不一致。**

#### 幻读（phantom read）

同样的条件，第一次和第二次读出来的记录数不一样。

幻读和不可重复读的区别在于，后者是两次读取同一条记录，得到不一样的结果；而前者是两次读取同一个范围内的记录，得到不一样的记录数（这种说法其实只是便于理解，但并不准确，因为可能存在另一个事务先插入一条记录然后再删除一条记录的情况，这个时候两次查询得到的记录数也是一样的，但这也是幻读，所以严格点的说法应该是：两次读取得到的结果集不一样。）

幻读是因为其他事务进行了 `INSERT` 或者 `DELETE` 操作。

**多次查询一定范围的数据时不一致。**

#### 丢失更新（lost update）

如果两个事务都是写入，可能会导致丢失更新问题。由于最后一步是提交操作，所以又叫做**提交覆盖**，有时候又叫 **Read-Modify-Write** 问题。一个典型的场景是并发对某个变量进行自增或自减。还有另一个 **丢失更新**问题，叫做**回滚覆盖**，一个事务的回滚操作影响另一个正常提交的事务。回滚覆盖问题可以说是程序 bug 了，因此几乎所有的数据库都不允许回滚覆盖。

有时候我们把**回滚覆盖**称之为**第一类丢失更新**问题，**提交覆盖**称为**第二类丢失更新**问题。

### 行级锁和表级锁

#### 表锁

在 MySQL 中锁的种类有很多，但是最基本的还是表锁和行锁。**表锁指的是对一整张表加锁**，一般是 `DDL` 处理时使用，也可以自己在 SQL 中指定；而**行锁指的是锁定某一行数据或某几行，或行和行之间的间隙**。行锁的加锁方法比较复杂，但是由于只锁住有限的数据，对于其它数据不加限制，所以并发能力强，通常都是用行锁来处理并发事务。表锁由 MySQL 服务器实现，行锁由存储引擎实现，常见的就是 `InnoDb`，所以通常我们在讨论行锁时，隐含的一层意义就是数据库的存储引擎为 `InnoDb` ，**而 `MyISAM` 存储引擎只能使用表锁**。

例如：

```mysql
lock table products read; # 为 products 加读锁
select * from products where id = 100; # 更新表数据
unlock tables; # 解锁
```

表锁可以细分成两种：**读锁**和**写锁**，如果是加写锁，则是 `lock table products write`。

关于表锁，我们要了解它的加锁和解锁原则，要注意的是它使用的是 **一次封锁** 技术，也就是说，我们会在会话开始的地方使用 `lock` 命令将后面所有要用到的表加上锁，在锁释放之前，我们只能访问这些加锁的表，不能访问其他的表，最后通过 `unlock tables` 释放所有表锁。这样的好处是，不会发生死锁！所以我们在 `MyISAM` 存储引擎中，是不可能看到死锁场景的。

MySQL 表锁的加锁规则如下：

- 对于读锁
  - 持有读锁的会话可以读表，但不能写表；
  - 允许多个会话同时持有读锁；
  - 其他会话就算没有给表加读锁，也是可以读表的，但是不能写表；
  - 其他会话申请该表写锁时会阻塞，直到锁释放。
- 对于写锁
  - 持有写锁的会话既可以读表，也可以写表；
  - 只有持有写锁的会话才可以访问该表，其他会话访问该表会被阻塞，直到锁释放；
  - 其他会话无论申请该表的读锁或写锁，都会阻塞，直到锁释放。

锁的释放规则如下：

- 使用 `UNLOCK TABLES` 语句可以显示释放表锁；
- 如果会话在持有表锁的情况下执行 `LOCK TABLES` 语句，将会释放该会话之前持有的锁；
- 如果会话在持有表锁的情况下执行 `START TRANSACTION` 或 `BEGIN` 开启一个事务，将会释放该会话之前持有的锁；
- 如果会话连接断开，将会释放该会话所有的锁。

表锁不仅实现和使用都很简单，而且占用的系统资源少，所以在很多存储引擎中使用，如 `MyISAM`、`MEMORY`、`MERGE` 等，`MyISAM` 存储引擎几乎完全依赖 MySQL 服务器提供的表锁机制，查询自动加表级读锁，更新自动加表级写锁，以此来解决可能的并发问题。但是表锁的粒度太粗，导致数据库的并发性能降低。

#### 行锁

为了提高数据库的并发能力，`InnoDB` 引入了行锁的概念。行锁和表锁对比如下：

- 表锁：开销小，加锁快；不会出现死锁；锁定粒度大，发生锁冲突的概率最高，并发度最低。
- 行锁：开销大，加锁慢；会出现死锁；锁定粒度最小，发生锁冲突的概率最低，并发度也最高。

行锁和表锁一样，也分成两种类型：**读锁**和**写锁**。常见的增删改（`INSERT`、`DELETE`、`UPDATE`）语句会**自动对操作的数据行加写锁**，查询的时候也可以明确指定锁的类型，`SELECT ... LOCK IN SHARE MODE` 语句**加的是读锁**，`SELECT ... FOR UPDATE` 语句**加的是写锁**。

**在 MySQL 中，行锁是加在索引上的。**



### 共享锁和独占锁

我们前边说过,并发事务的 `读-读` 情况并不会引起什么问题,不过对于 `写-写` 、 `读-写` 或 `写-读` 这些情况可能会引起一些问题,需要使用 `MVCC` 或者 加锁 的方式来解决它们。在使用 加锁 的方式解决问题时,由于既要允许 `读-读` 情况不受影响,又要使 `写-写` 、 `读-写` 或 `写-读` 情况中的操作相互阻塞,所以 MySQL给锁分了个类:

#### 锁介绍

**S锁和S锁是兼容的, S锁和X锁是不兼容的, X锁和X锁也是不兼容的。**

##### 共享锁（S锁）

**共享锁**:英文名: **Shared Locks** ,简称**S锁** 。在事务要读取一条记录时,需要先获取该记录的 S锁 。

##### 独占锁（X锁）

**独占锁**:英文名: **Exclusive Locks** ,简称**X锁**，也常称**排他锁**  。在事务要改动一条记录时,需要先获取该记录的 X锁 。

#### 锁定读

对读取的记录加X锁 :

```mysql
SELECT ... FOR UPDATE;
```

对读取的记录加S锁 :

```mysql
SELECT ... LOCK IN SHARE MODE;
```



#### 写操作

##### DELETE

对一条记录做 `DELETE` 操作的过程其实是先在 B+ 树中定位到这条记录的位置,然后获取一下这条记录的 X锁 ,然后再执行 `delete mark` 操作。我们也可以把这个定位待删除记录在 B+ 树中位置的过程看成是**一个获取 X锁的锁定读** 。

##### UPDATE

在对一条记录做 `UPDATE` 操作时分为三种情况:

1. 如果**未修改该记录的键值并且被更新的列占用的存储空间在修改前后未发生变化**,则先在 B+ 树中定位到这条记录的位置,然后再获取一下记录的 X锁 ,最后在原记录的位置进行修改操作。其实我们也可以把这个定位待修改记录在 B+ 树中位置的过程看成是一个**获取X锁的锁定读** 。

2. 如果**未修改该记录的键值**并且**至少有一个被更新的列占用的存储空间在修改前后发生变化**,则先在B+ 树中定位到这条记录的位置,然后获取一下记录的 X锁 ,将该记录彻底删除掉(就是把记录彻底移入垃圾链表),最后再插入一条新记录。这个定位**待修改记录**在 B+ 树中位置的过程看成是**一个获取 X 锁 的 锁定读** ,**新插入的记录**由 **`INSERT` 操作提供的隐式锁进行保护**。
3. 如果**修改了该记录的键值**,则**相当于在原记录上做 DELETE 操作之后再来一次 INSERT 操作**,加锁操作就**需要按照 `DELETE` 和 `INSERT` 的规则进行**了。

##### INSERT

**一般情况下,新插入一条记录的操作并不加锁**, `InnoDB`通过**隐式锁**来保护这条新插入的记录在本事务提交前不被别的事务访问。

##### 扩展：间隙锁（Gap Locks）

**间隙锁**是一种**加在两个索引之间**的锁，或者加在第一个索引之前，或最后一个索引之后的间隙。有时候又称为**范围锁**（Range Locks），这个范围可以**跨一个索引记录**，**多个索引记录**，甚至是**空的**。使用间隙锁可以防止其他事务在这个范围内插入或修改记录，保证两次读取这个范围内的记录不会变，从而不会出现幻读现象。很显然，**间隙锁会增加数据库的开销**，虽然解决了幻读问题，但是数据库的并发性一样受到了影响，所以在选择数据库的隔离级别时，要注意权衡性能和并发性，根据实际情况考虑是否需要使用间隙锁，大多数情况下使用 `read committed` 隔离级别就足够了，对很多应用程序来说，幻读也不是什么大问题。

### InnoDB 元数据锁

`MDL`全称为`metadata lock`，即元数据锁。`MDL`锁主要作用是维护表元数据的数据一致性，在表上有活动事务（显式或隐式）的时候，不可以对元数据进行写入操作。因此从MySQL5.5版本开始引入了`MDL`锁，来保护表的元数据信息，用于解决或者保证`DDL`操作与`DML`操作之间的一致性。

对于引入`MDL`，其主要解决了2个问题，一个是事务隔离问题，比如在可重复隔离级别下，会话A在2次查询期间，会话B对表结构做了修改，两次查询结果就会不一致，无法满足可重复读的要求；另外一个是数据复制的问题，比如会话A执行了多条更新语句期间，另外一个会话B做了表结构变更并且先提交，就会导致slave在重做时，先重做`alter`，再重做`update`时就会出现复制错误的现象。

元数据锁是server层的锁，表级锁，每执行一条`DML`、`DDL`语句时都会申请`MDL`锁，`DML`操作需要`MDL`读锁，`DDL`操作需要`MDL`写锁（`MDL`加锁过程是系统自动控制，无法直接干预，读读共享，读写互斥，写写互斥），申请`MDL`锁的操作会形成一个队列，队列中写锁获取优先级高于读锁。一旦出现写锁等待，不但当前操作会被阻塞，同时还会阻塞后续该表的所有操作。事务一旦申请到`MDL`锁后，直到事务执行完才会将锁释放。（这里有种特殊情况如果事务中包含`DDL`操作，mysql会在`DDL`操作语句执行前，隐式提交`commit`，以保证该`DDL`语句操作作为一个单独的事务存在，同时也保证元数据排他锁的释放）。

注： 支持事务的`InnoDB`引擎表和不支持事务的`MyISAM`引擎表，都会出现`Metadata Lock Wait`等待现象。一旦出现`Metadata Lock Wait`等待现象，后续所有对该表的访问都会阻塞在该等待上，导致连接堆积，业务受影响。

`MDL`锁通常发生在`DDL`操作挂起的时候，原因是有未提交的事务对该表进行`DML`操作。而`MySQL`的会话那么多，不知道哪个会话的操作没有及时提交影响了`DDL`。通常我们排查这类问题，往往需要从`information_schema.innodb_trx`表中查询当前在执行的事务，但当`SQL`已经执行过了，没有`commit`，这个时候这个表中是看不到`SQL`的。

`MDL`锁一旦发生会对业务造成极大影响，因为后续所有对该表的访问都会被阻塞，造成连接积压。

### 死锁

#### 案例一

|                     事务A                     |                     事务B                     |
| :-------------------------------------------: | :-------------------------------------------: |
| `UPDATE stundents score = 100 WHERE id = 20;` |                                               |
|                                               | `UPDATE stundents score = 100 WHERE id = 30;` |
| `UPDATE stundents score = 100 WHERE id = 30;` |                                               |
|                                               | `UPDATE stundents score = 100 WHERE id = 20;` |

死锁的根本原因是有两个或多个事务之间加锁顺序的不一致导致的，这个死锁案例其实是最经典的死锁场景。

首先，事务 A 获取 id = 20 的锁（lock_mode X locks rec but not gap），事务 B 获取 id = 30 的锁；然后，事务 A 试图获取 id = 30 的锁，而该锁已经被事务 B 持有，所以事务 A 等待事务 B 释放该锁，然后事务 B 又试图获取 id = 20 的锁，这个锁被事务 A 占有，于是两个事务之间相互等待，导致死锁。

#### 如何避免死锁

在工作过程中偶尔会遇到死锁问题，虽然这种问题遇到的概率不大，但每次遇到的时候要想彻底弄懂其原理并找到解决方案却并不容易。其实，对于 MySQL 的 `InnoDB` 存储引擎来说，死锁问题是避免不了的，没有哪种解决方案可以说完全解决死锁问题，但是我们可以通过一些可控的手段，降低出现死锁的概率。

1. **对索引加锁顺序的不一致很可能会导致死锁**，所以如果可以，尽量以相同的顺序来访问索引记录和表。在程序以批量方式处理数据的时候，如果事先对数据排序，保证每个线程按固定的顺序来处理记录，也可以大大降低出现死锁的可能；

2. **Gap 锁往往是程序中导致死锁的真凶**，由于默认情况下 MySQL 的隔离级别是 RR，所以如果能确定幻读和不可重复读对应用的影响不大，可以考虑将**隔离级别改成 RC**，可以避免 Gap 锁导致的死锁；

3. **为表添加合理的索引**，如果不走索引将会为表的每一行记录加锁，死锁的概率就会大大增大；

4. 我们知道 MyISAM 只支持表锁，它采用一次封锁技术来保证事务之间不会发生死锁，所以，我们也可以使用同样的思想，**在事务中一次锁定所需要的所有资源，减少死锁概率**；
5. **避免大事务，尽量将大事务拆成多个小事务来处理**；因为大事务占用资源多，耗时长，与其他事务冲突的概率也会变高；

6. **避免在同一时间点运行多个对同一表进行读写的脚本，**特别注意加锁且操作数据量比较大的语句；我们经常会有一些定时脚本，避免它们在同一时间点运行；

7. **设置锁等待超时参数**：`innodb_lock_wait_timeout`，这个参数并不是只用来解决死锁问题，在并发访问比较高的情况下，如果大量事务因无法立即获得所需的锁而挂起，会占用大量计算机资源，造成严重性能问题，甚至拖跨数据库。我们通过设置合适的锁等待超时阈值，可以避免这种情况发生。

## 扩展内容

### 视图

### 存储过程

### 触发器

### 为什么要使用索引? `innodb`的数据存储方式

### 为什么要使用索引?没有索引时是如何查找数据的

### 为什么要使用分布式数据库?它解决哪些问题

**分布式数据库**是用计算机网络将**物理上分散**的多个数据库单元连接起来组成的一个**逻辑上统一**的数据库。每个被连接起来的数据库单元称为站点或节点。分布式数据库有一个统一的数据库管理系统来进行管理，称为分布式数据库管理系统。

解决的问题：

- 高并发

- 异地双活

- 数据量大

  

### 分布式数据库的物理架构

### 分布式数据库的逻辑架构

### 垂直拆分

### 水平拆分

拆分键规则：值分布均匀、高频使用、列值稳定、列值非空、同事务同源



## 扩展

### 名词解释

#### **DDL**

数据定义语言 (Data Definition Language）用于定义SQL模式、基本表、视图和索引的创建和撤消操作。

例如：`CREATE`、`ALTER` 、 `DROP`、`TRUNCATE`、`COMMENT`、`RENAME`

#### **DML**

数据操控语言（Data Manipulation Language) 数据操纵分成数据查询和数据更新两类。数据更新又分成插入、删除、和修改三种操作。

例如：`INSERT`、`UPDATE`、`DELETE`

#### **DQL**

数据查询语言 (Data Query Language) 用于查询数据。

例如：`SELECT`

#### **DCL**
数据库控制语言（Data Control Language）  负责授权，角色控制等。
例如：`GRANT` 、`REVOKE`


#### **TCL**

事务控制语言（Transaction Control Language）事务控制语言。
例如：`SAVEPOINT`、`ROLLBACK`、`SET TRANSACTION`


## 参考

1. [解决死锁之路 - 学习事务与隔离级别](https://www.aneasystone.com/archives/2017/10/solving-dead-locks-one.html)
1. [MySQL 常用函数介绍](https://juejin.cn/post/6844903977830580231)