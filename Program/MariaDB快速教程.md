# MariaDB 教程

> 此笔记使用的版本为 `10.6.4-MariaDB`

查看完整教程请前往 [mariadbtutorial](https://www.mariadbtutorial.com)

## 基础教程

### 查询 `SELECT`

#### 简单查询

一个简单的查询如下所示：

```sql
SELECT * from countries;
```

也可以定制输出的样式：

```sql
select name,area,national_day
from countries;
```

还可以直接查询函数：

```sql
SELECT now();
```

#### 排序 `order by`

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

例如：

```sql
select name,area
from countries order by name;
```

或者

```sql
select name,area
from countries order by name desc ;
```

默认情况下，不加 `desc` 为升序 （asc）

#### 条件 `where`

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

```sql
select name
from countries
where name like '%A_'
order by name;

# 查询倒数第二个字母为 A 的国家
```

#### 正则表达式  `regexp`


MySQL 仅支持多数正则表达式实现的一个很小的子集。

##### 基本字符匹配

```sql
SELECT * FROM `user` WHERE `name` REGEXP '100';
# 匹配名字带 100 的用户
```
或者：

```sql
SELECT * FROM `user` WHERE `name` REGEXP '.00'; 
# 匹配包含整百的名字，如100,200,300等等
```

##### 进行OR匹配

```sql
SELECT * FROM `user` WHERE `name` REGEXP '100|200';
# 匹配名字包含 100 或 200 的用户 
```

使用or查询的情况，有点儿类似于`SELECT`中使用`OR`条件连接的情况，你可以把它们想象成并入了一个正则表达式。

##### 匹配几个字符之一

正则匹配中有一种特殊的`OR`匹配。

```sql
SELECT * FROM `user` WHERE `name` REGEXP '[12]';
```

上面表达式中我们使用了一个特殊的字符串`[12]`，这个字符串的含义是：查询名字中包含有数字1或者数字2的记录，它是`[1|2]`的缩写。

字符串还可以查询被否定的情况。例如：

```sql
SELECT * FROM `user` WHERE `name` REGEXP '[^12]';
```

`[^12]`如果在12之前加上一个`^`符号，那么就代表除了1或2外的字符串。

##### 匹配范围

集合可用来定义要匹配的一个或多个字符。例如, `[0123456789]`将匹配数字0到9，可简化成 `[0-9]`。

例如：

```sql
SELECT * FROM `user` WHERE `name` REGEXP '[0-9]';
```

这里的范围不仅仅只能是数字，还可以是字母。比如`[a-z]`就是表示从字母a到字母z的所有数字，26个字母。小写完了，还有大写`[A-Z]`。那么我们将其组合起来`[0-9a-zA-Z]`这个表达式就十分强大了，可以表示包含数字，小写字母，大写字母的所有记录。

```sql
SELECT * FROM `user` WHERE `name` REGEXP '[0-9a-zA-Z]';
```

##### 匹配特殊字符

正则表达式语言由具有特定含义的特殊字符构成。为了匹配特殊字符,必须用`\\`为前导。` \\-`表示查找`-`,` \\.`表示查找`.`。

```sql
SELECT * FROM `tablle` WHERE `name` REGEXP '\\[ '; #匹配左方括号
SELECT * FROM `tablle` WHERE `name` REGEXP '\\. '; #匹配点号
SELECT * FROM `tablle` WHERE `name` REGEXP '\\] '; #匹配右方括号
SELECT * FROM `tablle` WHERE `name` REGEXP '\\| '; #匹配竖线
SELECT * FROM `tablle` WHERE `name` REGEXP '\\\ '; #匹配反斜杠自己本身
```

例如：

```sql
SELECT * FROM `user` WHERE `name` REGEXP '\\.12';
# 查询名字包含 .12 的用户
```
双反斜杠加上一些字母还可以表示特殊的含义。例如：

```sql
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

```sql
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

```sql
SELECT * FROM user WHERE `name` REGEXP '[0-9]*'; 
# 匹配名字包含或者不包含数字的记录
```

或者：

```sql
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

```sql
SELECT * FROM user WHERE `name` REGEXP '^[0-9]{11}$';
# 从头开始匹配到结尾，是11位数字
```

#### 去重 `distinct`

查询一行并去除重复内容，仅保留一个

```sql
select distinct national_day
from countries;
```

请注意，如果您只想选择某些列的不同值，请使用 `group by`.

#### 批量匹配 `in`

语法如下：

```sql
expression IN (v1, v2, v3, ...)

# 类似于
# expression = v1 or 
# expression = v2 or 
# expression = v3 or
```

或者

```sql
expression in (select-statement)

# 注意 select-statement必须返回只有一列值的列表
```

例如：

```sql
select name,
       region_id
from countries
where region_id in (1, 2, 3)
order by name;

# 查询区域id 为 1、2、3 的国家名称
select name,
       region_id
from countries
where region_id = 1
   or region_id = 2
   or region_id = 3
order by name; 
# 上面代码等价于此
```

子查询例子如下：

```sql
select region_id
from regions
where name like '%Asia%';

select name,
       region_id
from countries
where region_id in (2, 16, 18)
order by name;

# 上面两条可合并成一条语句

select name,
       region_id
from countries
where region_id in (
    select region_id
    from regions
    where name like '%Asia%'
)
order by name;
```

#### 控制返回数

语法如下

```sql
select select_list
from tale_name
order by sort_expression
limit n [offset m];
# n是要返回的行数
# m是在返回之前要跳过的行数 n行。 
# LIMIT m, n;
```

示例

```sql
select name
from countries
order by name
limit 5 offset 1;

# 查询前5个国家并跳过第一个
```

#### 空检查 `is null`

```sql
select name,
       national_day
from countries
where national_day is null
order by name;

# 查询 national_day 为空的国家

select name,
       national_day
from countries
where national_day is not null
order by name;

# 查询 national_day 不为空的国家

```

#### 连接查询 `join`

##### 内连接 `inner join`

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

##### 左连接 `left join`

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

##### 右连接 `right join`

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

##### 笛卡尔积 `cross join`

对连接表中的行进行笛卡尔积处理。

```sql
select g.guest_id,
       g.name,
       v.vip_id,
       v.name
from guests g
         cross join vips v;

```

#### 归组 `group by`

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

#### 复杂子查询 `in`

子查询是嵌套在另一个查询中的查询。

##### 标量子查询

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

##### 行子查询

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

##### FROM 下的子查询

你可以将子查询放在 FROM 后

```sql
select avg(region_area)
from (
         select sum(area) region_area
         from countries
         group by region_id
     ) t;
```

#### 公用表达式 `CTE`

公用表表达式或 CTE 允许您在查询中创建临时结果集。

CTE 类似于派生表，因为它不存储为数据库对象，并且仅在执行查询期间存在。

与派生表不同，您可以在查询中多次引用 CTE。 此外，您可以在其内部引用 CTE。 此 CTE 称为递归 CTE。

CTE 可用于

- 在同一语句中多次引用结果集。
- 替换 视图 以避免创建视图。
- 创建递归查询
- 通过将复杂查询分解为多个简单且符合逻辑的构建块来简化它。

语法如下

```sql
with cte_name as (
    cte_body
)
cte_usage;
```

示例

```sql
select name,
       gdp
from country_stats
         inner join countries c
                    using (country_id)
where year = 2018
order by gdp desc
limit 10;

# 以下代码等价于上面代码

with d as (
    select country_id, gdp
    from country_stats
    where year = 2018
    order by gdp desc
    limit 10
)
select name, gdp
from countries
         inner join d using (country_id)

# 查询 2018 年排名前10 GDP
```

### 组合 union

 union运算符组合两个或多个结果集合并为一个结果集。

语法如下 ：

```sql
select-statement1
union [all | distinct]
select-statement2
union [all | distinct]
```

`distinct`选项表示 `union`运算符从最终结果集中删除重复行，而 `all`选项保留重复项。

示例：

```sql
select name from guests
union distinct
select name from vips
order by name;
```

`union`对比 `join`

`join`水平追加结果集，而 `union`垂直追加结果集。

#### 相交 `intersect`

`intersect`运算符组合两个或多个结果集并从查询的结果集中返回相同的行。

语法如下：

```sql
select-statement1
intersect
select-statement2
intersect 
select-statement3
...
[order by sort_expression];
```

示例：

```sql
select name from guests
    intersect
    select name from vips
    order by name;
# 查询 guests 和 vips 下相同的人
```

#### 排除 `except`

`except`运算符用于去除第一个结果集中其他结果集的数据

语法：

```sql
select-statement
except
select-statement;
```

示例：

```sql
select name from guests
    except
select name from vips
order by name;

# 从 guests 结果中排除 vips
```

### 插入 `insert`

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

### 更新 `update`

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

### 删除 `delete`

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

## 数据库操作

### 创建数据库

语法：

```sql
create [or replace] database [if not exists] database_name
[character set = charset_name]
[collate = collation_name];
``

可以使用以下语法删除到创建数据库

```sql
drop database if exists database_name;
create database database_name;
```

### 更改数据库

语法

```sql
alter database [database_name]
[character set charset_name]
[collate collation_name]
```

示例：

```sql
alter database crm
 character set = 'latin1'
 collate = 'latin1_swedish_ci';
```

### 删除数据库

示例：

```sql
drop database crm;
```

## 数据类型

### 数字数据类型

| 数字类型    | 描述               |
| ----------- | ------------------ |
| `TINYINT`   | 一个非常小的整数   |
| `SMALLINT`  | 一个小整数         |
| `MEDIUMINT` | 一个中等大小的整数 |
| `INT`       | 标准整数           |
| `BIGINT`    | 一个大整数         |
| `DECIMAL`   | 一个定点数         |
| `FLOAT`     | 单精度浮点数       |
| `DOUBLE`    | 双精度浮点数       |
| `BIT`       | 一比特             |

### 字符串数据类型

| 字符串类型   | 描述                              |
| ------------ | --------------------------------- |
| `CHAR`       | 固定长度的非二进制（字符）字符串  |
| `VARCHAR`    | 可变长度的非二进制字符串          |
| `BINARY`     | 一个固定长度的二进制字符串        |
| `VARBINARY`  | 可变长度的二进制字符串            |
| `TINYBLOB`   | 一个非常小的 BLOB（二进制大对象） |
| `BLOB`       | 一个小BLOB                        |
| `MEDIUMBLOB` | 一个中等大小的 BLOB               |
| `LONGBLOB`   | 一个大BLOB                        |
| `TINYTEXT`   | 一个非常小的非二进制字符串        |
| `TEXT`       | 一个小的非二进制字符串            |
| `MEDIUMTEXT` | 一个中等大小的非二进制字符串      |
| `LONGTEXT`   | 一个大的非二进制字符串            |
| ENUM         | 枚举                              |
| `SET`        | SET                               |

### 时间类型

| 时态数据类型 | 描述                                       |
| ------------ | ------------------------------------------ |
| `DATE`       | 中的日期值 `CCYY-MM-DD`格式                |
| `TIME`       | 时间值在 `hh:mm:ss`格式                    |
| `DATETIME`   | 中的日期和时间值 `CCYY-MM-DD hh:mm:ss`格式 |
| `TIMESTAMP`  | 中的时间戳值 `CCYY-MM-DD hh:mm:ss`格式    |
| `YEAR`       | 一年中的价值 `CCYY`或者 `YY`格式          |

### 空间数据类型

| 空间数据类型         | 描述                         |
| -------------------- | ---------------------------- |
| `GEOMETRY`           | 任何类型的空间值             |
| `POINT`              | 一个点（一对XY坐标）         |
| `LINESTRING`         | 曲线（一个或多个 `POINT`值） |
| `POLYGON`            | 一个多边形                   |
| `GEOMETRYCOLLECTION` | GEOMETRY                     |
| `MULTILINESTRING`    | LINESTRING                   |
| `MULTIPOINT`         | POINT                        |
| `MULTIPOLYGON`       | POLYGON                      |

## 表管理

### 创建表

基本语法：

```sql
create table [if not exists] table_name(
    column_1_definition,
    column_2_definition,
    ...,
    table_constraints
) engine=storage_engine;
```

列定义语法：

```sql
column_name data_type(length) [not null] [default value] [auto_increment] column_constraint;
```

- 首先，指定列的名称。
- 接下来，如果数据类型需要，指定列的数据类型和最大长度。
- 然后，使用 `not null`强制列中的非空值。  除了非空约束，您还可以对列使用检查和主键列约束。
- 之后，使用 `default value`当插入和更新语句未明确指定时，子句为列指定默认值。
- 最后，使用 `auto_increment`属性指示 MariaDB 为列隐式生成连续整数。  一张表只有一列 `auto_increment`。

例如：

```sql
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

定义外键：

示例：

```sql
create table milestones(
    milestone_id int auto_increment,
    project_id int,
    milestone varchar(255) not null,
    start_date date not null,
    end_date date not null,
    completed bool default false,
    primary key(milestone_id, project_id),
    foreign key(project_id)
        references projects(project_id)
);
```

使用以下语句进行关联：

```sql
foreign key(project_id)
    references projects(project_id)
```

### 更改表

#### 添加列

语法:

```sql
alter table table_name
add 
    new_column_name column_definition
    [first | after column_name]
```

示例：

```sql
alter table customers
add email varchar(255) not null;
# 在customers后添加一行email
```

向表中添加多列

语法：

```sql
alter table table_name
    add new_column_name column_definition
    [first | after column_name],
    add new_column_name column_definition
    [first | after column_name],
    ...;
```

示例：

```sql
alter table customers
add phone varchar(15),
add address varchar(255);
```

#### 修改列

语法：

```sql
alter table table_name
modify column_name column_definition
[ first | after column_name];    
```

示例：

```sql
alter table customers 
modify phone varchar(20) not null;
```

修改多列

语法：

```sql
alter table table_name
    modify column_name column_definition
    [ first | after column_name],
    modify column_name column_definition
    [ first | after column_name],
    ...;
```

示例：

```sql
alter table customers 
modify email varchar(255),
modify address varchar(255) after name;
```

#### 重命名列

语法：

```sql
alter table table_name
change column original_name new_name column_definition
[first | after column_name];
```

示例：

```sql
alter table customers
change column address office_address varchar(255) not null;
```

#### 删除列

语法：

```sql
alter table table_name
drop column column_name;  
```

示例：

```sql
alter table customers
drop column office_address;
```

#### 重命名表

语法：

```sql
alter table table_name
rename to new_table_name;
```

示例：

```sql
alter table customers 
rename to clients; 
```

### 删除表

语法：

```sql
drop table [if exists] table_name;
```

一次删除多个：

```sql
drop table [if exists]
    table1,
    table2,
       ...;
```

### 查看所有表

语法:

```sql
show full tables;
```

可以附加条件

例如：

```sql
show full tables
like 'country%'
```

或者：

```sql
show full tables
where table_type = 'view';
```

### 清空表

语法:

```sql
truncate [table] table_name;
```

### 表约束

#### 主键约束

##### 定义主键

语法:

```sql
create table table_name(
    pk_column type primary key,
    ...
);
```

如果有多个主键则使用如下定义

```sql
create table table_name(
    pk_column1 type,
    pk_column2 type,
    ...
    primary key(pk_column1,pk_column2,)
);
```

##### 添加主键

语法:

```sql
alter table table_name
add constraint constraint_name
primary key (column_list);
```

##### 删除主键

```sql
alter table table_name
drop primary key;
```

##### 定义自增主键

例如：

```sql
create table categories(
    category_id int auto_increment,
    name varchar(50) not null,
    primary key(category_id)
);
```

#### 外键约束

外键是表中的一列或一组列，它引用另一个表中的一列或一组列，它强制执行两个表之间的参照完整性。 具有外键的表称为子表，而外键引用的表称为父表。通常，子表中的外键列引用父表的主键列。

##### 创建外键

```sql
create table table_name(
    column_list,
    ...,
    [constraint constraint_name]
 foreign key [fk_name](column_list) references parent_table(column_list)
 [on delete reference_option]
 [on update reference_option]
);
```

示例:

```sql
create table gadgets
(
    gadget_id   int auto_increment,
    gadget_name varchar(100) not null,
    type_id     int,
    primary key (gadget_id),
    constraint fk_type
        foreign key (type_id)
            references gadget_types (type_id)
);
```

##### 添加外键

```sql
alter table table_name
[constraint fk_constraint_name]
foreign key [fk_name](column_list) references parent_table(column_list)
[on delete reference_option]
[on update reference_option]
```

示例：

```sql
alter table gadgets
    add constraint fk_type
        foreign key (type_id)
            references gadget_types (type_id)
            on delete cascade
            on update cascade;
```

##### 删除外键

```sql
alter table table_name
drop constraint fk_constraint_name;
```

示例：

```sql
alter table gadgets
drop constraint fk_type;
```

#### 检查约束

示例：

```sql
create table classes(
    class_id int auto_increment,
    class_name varchar(255) not null,
    student_count int check(student_count >0),
    primary key(class_id)
);
```

语法：

```sql
column_name datatype check(expression)
```

向现有的表添加检查约束：

语法：

```sql
alter table table_name
add constraint constraint_name 
check(expression);
```

示例：

```sql
alter table classes
add constraint valid_begin_date 
check(begin_date >= '2019-01-01');
```

删除检查约束

语法：

```sql
alter table table_name
drop constraint constraint_name;
```

示例：

```sql
alter table classes
drop constraint valid_begin_date;
```

#### 唯一约束

有时，您可能希望确保一列或一组列中的值是唯一的，例如，国家/地区的国家/地区代码、客户的电子邮件地址等。这时你就可以使用唯一约束.

语法：

```sql
create table table_name(
    ...,
    column_name datatype unique,
    ...
);
```

或者使用如下语法：

```sql
create table table_name(
    ...
    column1 datatype,
    column2 datatype,
    ...,
    unique(column1,column2,...)
);
```

你也可以对现有的表添加约束

```sql
alter table table_name
add constraint constraint_name 
unique (column_list);
```

删除约束

```sql
drop index_name on table_name;
```

或者

```sql
alter table table_name
drop index index_name;
```

#### 非空约束

语法：

```sql
column_name datatype not null;
```

示例：

```sql
create table courses(
    course_id int auto_increment,
    course_name varchar(100) not null,
    summary varchar(255),
    primary key(course_id)
);
```

更新表约束

```sql
alter table courses
modify summary varchar(255) not null;
```

注意，你需要先将列中 `null`数据更新为非 `null`数据

例如：

```sql
update courses
set summary = 'N/A'
where summary is null;
```

删除约束

```sql
alter table table_name
modify column_name datatype;
```
