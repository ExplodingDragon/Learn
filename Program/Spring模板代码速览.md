# Spring 学习

## Spring Framework

### Spring Core

#### IoC 容器

##### 创建容器

```kotlin
import org.springframework.beans.factory.getBean
import org.springframework.context.support.ClassPathXmlApplicationContext

fun main() {
    val ioc = ClassPathXmlApplicationContext("/spring-core-xml-ioc.xml")
    ioc.getBean<SpringCoreXmlIoc.BeanA>("bean1").sayHello()
}

class SpringCoreXmlIoc {
    class BeanA(
        private val hello: String = ""
    ) {
        fun sayHello() {
            println(hello)
        }
    }
}

```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean name="bean1" class="SpringCoreXmlIoc.BeanA">
        <constructor-arg name="hello" value="Hello"/>
    </bean>
</beans>

```

或者，可以使用另一种方案初始化

```kotlin
import org.springframework.beans.factory.getBean
import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.support.GenericApplicationContext

fun main() {
    val context = GenericApplicationContext()
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring-core-xml-ioc.xml")
    context.refresh()
    context.getBean<SpringCoreXmlIoc.BeanA>("bean1").sayHello()
}

class SpringCoreXmlIoc {
    class BeanA(
        private val hello: String = ""
    ) {
        fun sayHello() {
            println(hello)
        }
    }
}

```

通过工厂方法创建

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean name="father" class="SpringCoreXmlIoc"/>
    <bean name="bean1" factory-bean="father" factory-method="createBeanA"/>
</beans>

```

```kotlin

import org.springframework.beans.factory.getBean
import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.support.GenericApplicationContext

fun main() {
    val context = GenericApplicationContext()
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring-core-xml-ioc.xml")
    context.refresh()
    context.getBean<SpringCoreXmlIoc.BeanA>("bean1").sayHello()
}

object SpringCoreXmlIoc {
    class BeanA(
        private val hello: String = ""
    ) {
        fun sayHello() {
            println(hello)
        }
    }

    fun createBeanA(): BeanA {
        return BeanA("Hello")
    }
}
```

##### 依赖注入

构造函数注入

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean name="a" class="SpringCoreXmlIoc.DataA"/>
    <bean name="b" class="SpringCoreXmlIoc.DataB">
        <constructor-arg name="dataA" ref="a"/>
    </bean>
</beans>
```

```kotlin
import org.springframework.beans.factory.getBean
import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.support.GenericApplicationContext

fun main() {
    val context = GenericApplicationContext()
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring-core-xml-ioc.xml")
    context.refresh()
    val bean = context.getBean<SpringCoreXmlIoc.DataB>("b")
    bean.say()
}

object SpringCoreXmlIoc {
    class DataA {
        val hello = "Hello"
    }

    class DataB(private val dataA: DataA) {
        fun say() {
            println(dataA.hello)
        }
    }
}
```

Set 注入

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean name="a" class="SpringCoreXmlIoc.DataA"/>
    <bean name="b" class="SpringCoreXmlIoc.DataB">
        <property name="dataA" ref="a"/>
    </bean>
</beans>
```

```kotlin
import org.springframework.beans.factory.getBean
import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.support.GenericApplicationContext

fun main() {
    val context = GenericApplicationContext()
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring-core-xml-ioc.xml")
    context.refresh()
    val bean = context.getBean<SpringCoreXmlIoc.DataB>("b")
    bean.say()
}

object SpringCoreXmlIoc {
    class DataA {
        val hello = "Hello"
    }

    class DataB {
        lateinit var dataA: DataA
        fun say() {
            println(dataA.hello)
        }
    }
}
```

简化XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean name="dataSource" class="SpringCoreXmlIoc.DataSource">
        <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
        <property name="url" value="jdbc:mysql://localhost:3306/mydb"/>
        <property name="userName" value="root"/>
        <property name="password" value="123456"/>
    </bean>
</beans>
```

```kotlin
import org.springframework.beans.factory.getBean
import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.support.GenericApplicationContext

fun main() {
    val context = GenericApplicationContext()
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring-core-xml-ioc.xml")
    context.refresh()
    val bean = context.getBean<SpringCoreXmlIoc.DataSource>("dataSource")
    println(bean)
}

object SpringCoreXmlIoc {
    class DataSource{
        lateinit var driverClassName: String
        lateinit var url: String
        lateinit var userName: String
        lateinit var password: String
    }
}

```

可以将 XML 简化成

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean name="dataSource" class="SpringCoreXmlIoc.DataSource"
          p:driverClassName="com.mysql.jdbc.Driver"
          p:url="jdbc:mysql://localhost:3306/mydb"
          p:userName="root"
          p:password="123456"
    >
    </bean>
</beans>

```

甚至你可以直接注入 `properties`

```kotlin
import org.springframework.beans.factory.getBean
import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.support.GenericApplicationContext
import java.util.Properties

fun main() {
    val context = GenericApplicationContext()
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring-core-xml-ioc.xml")
    context.refresh()
    val bean = context.getBean<SpringCoreXmlIoc.DataSource>("dataSource")
    println(bean.property)
}

object SpringCoreXmlIoc {
    class DataSource {
        lateinit var property: Properties
    }
}
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
    https://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean name="dataSource" class="SpringCoreXmlIoc.DataSource">
        <property name="property">
            <value>
                jdbc.driver.className=com.mysql.jdbc.Driver
                jdbc.url=jdbc:mysql://localhost:3306/mydb
            </value>
        </property>
    </bean>
</beans>
```

##### 工厂Bean

```kotlin
import org.springframework.beans.factory.FactoryBean
import org.springframework.beans.factory.getBean
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.stereotype.Component

fun main() {

    val context = AnnotationConfigApplicationContext(Data.MyFactoryBean::class.java)
    val bean1 = context.getBean<Data.ChildData>("myFactory")
    println(bean1.id)
}

object Data {
    class ChildData {
        val id: String = "id"
    }
    @Component("myFactory")
    class MyFactoryBean : FactoryBean<ChildData> {
        override fun getObject(): ChildData {
            return ChildData()
        }

        override fun getObjectType(): Class<*>? {
            return ChildData::class.java
        }
    }
}
```

##### Bean 作用域

```kotlin
import org.springframework.beans.factory.getBean
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Scope
import org.springframework.stereotype.Component

fun main() {

    val context = AnnotationConfigApplicationContext(Data.ChildData::class.java)
    println(context.getBean<Data.ChildData>("a"))
    println(context.getBean<Data.ChildData>("a"))
}

object Data {
    @Component("a")
    @Scope("prototype")
    class ChildData {
        val id: String = "id"
    }
}
```

##### Bean的生命周期

```kotlin

import org.springframework.beans.factory.config.BeanPostProcessor
import org.springframework.beans.factory.getBean
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Bean

fun main() {

    val context = AnnotationConfigApplicationContext(Data.AppConfig::class.java, Data.MyBeanPostProcessor::class.java)
    println(context.getBean<Data.ChildData>("a"))
    println(context.getBean<Data.ChildData>("a").id)
    context.close()
}

object Data {
    class ChildData {
        val id: String = "id"
        fun initMethod() {
            println("Init")
        }

        private fun destroy() {
            println("Destroy")
        }
    }

    class AppConfig {
        @Bean("a", initMethod = "initMethod", destroyMethod = "destroy")
        fun getBean() = ChildData()
    }

    class MyBeanPostProcessor : BeanPostProcessor {
        override fun postProcessAfterInitialization(bean: Any, beanName: String): Any? {
            println("after ${bean::class.qualifiedName}")
            return super.postProcessAfterInitialization(bean, beanName)
        }

        override fun postProcessBeforeInitialization(bean: Any, beanName: String): Any? {
            println("before ${bean::class.qualifiedName}")
            return super.postProcessBeforeInitialization(bean, beanName)
        }
    }
}
```

##### Spring 自动装配

```kotlin

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.stereotype.Component

fun main() {

    val context = AnnotationConfigApplicationContext(AutoWrite.Groups::class.java, AutoWrite.User::class.java)
    println(context.getBean(AutoWrite.User::class.java).group.name)
    context.close()
}

object AutoWrite {
    @Component
    class User {
        @Autowired
        @Qualifier("group1")
        lateinit var group: Group
    }

    class Group(val name: String)

    class Groups {
        @Bean("group1")
        fun g1() = Group("group1")

        @Bean("group2")
        fun g2() = Group("group2")
    }
}

```

#### AOP

##### 术语

- 连接点
- 切入点
- 通知
- 切面

##### AspectJ AOP 切面

```kotlin
implementation("org.springframework:spring-aspects:5.3.9")
```

```kotlin
import org.aspectj.lang.ProceedingJoinPoint
import org.aspectj.lang.annotation.After
import org.aspectj.lang.annotation.AfterReturning
import org.aspectj.lang.annotation.AfterThrowing
import org.aspectj.lang.annotation.Around
import org.aspectj.lang.annotation.Aspect
import org.aspectj.lang.annotation.Before
import org.springframework.beans.factory.getBean
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.EnableAspectJAutoProxy
import org.springframework.stereotype.Component

fun main() {

    val context = AnnotationConfigApplicationContext()
    context.register(
        AppConfig::class.java,
        SpringData.UserProxy::class.java,
        SpringData.User::class.java
    )
    context.refresh()
    val bean = context.getBean<SpringData.User>()
    bean.add()
    context.close()
}

// @ComponentScan("impl")
@Configuration
@EnableAspectJAutoProxy
open class AppConfig

class SpringData {

    @Component
    open class User {
        open fun add() {
            println("add")
        }
    }

    @Aspect
    @Component
    class UserProxy {
        @Before(value = "execution(* SpringData\$User.add())")
        fun before() {
            println("before")
        }

        @After(value = "execution(* SpringData\$User.add())")
        fun after() {
            println("after")
        }
        @AfterThrowing(value = "execution(* SpringData\$User.add())")
        fun afterThrow() {
            println("after throws " )
        }

        @AfterReturning(value = "execution(* SpringData\$User.add())")
        fun afterReturn() {
            println("afterReturn")
        }

        @Around(value = "execution(* SpringData\$User.add())")
        fun around(func: ProceedingJoinPoint) {
            println("around before")
            func.proceed()
            println("around after")
        }
    }
}
```

##### 抽取公共切入点

```kotlin
import org.aspectj.lang.ProceedingJoinPoint
import org.aspectj.lang.annotation.After
import org.aspectj.lang.annotation.AfterReturning
import org.aspectj.lang.annotation.AfterThrowing
import org.aspectj.lang.annotation.Around
import org.aspectj.lang.annotation.Aspect
import org.aspectj.lang.annotation.Before
import org.aspectj.lang.annotation.Pointcut
import org.springframework.beans.factory.getBean
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.EnableAspectJAutoProxy
import org.springframework.stereotype.Component

fun main() {

    val context = AnnotationConfigApplicationContext()
    context.register(
        AppConfig::class.java,
        SpringData.UserProxy::class.java,
        SpringData.User::class.java
    )
    context.refresh()
    val bean = context.getBean<SpringData.User>()
    bean.add()
    context.close()
}

@Configuration
@EnableAspectJAutoProxy
open class AppConfig

class SpringData {

    @Component
    open class User {
        open fun add() {
            println("add")
        }
    }

    @Aspect
    @Component
    class UserProxy {
        @Pointcut("execution(* SpringData\$User.add())")
        fun point() {
        }

        @Before(value = "point()")
        fun before() {
            println("before")
        }

        @After(value = "point()")
        fun after() {
            println("after")
        }

        @AfterThrowing(value = "point()")
        fun afterThrow() {
            println("after throws ")
        }

        @AfterReturning(value = "point()")
        fun afterReturn() {
            println("afterReturn")
        }

        @Around(value = "point()")
        fun around(func: ProceedingJoinPoint) {
            println("around before")
            func.proceed()
            println("around after")
        }
    }
}

```

##### 多个增强类编辑顺序

添加注解 `@Order(Int)`

```kotlin
import org.aspectj.lang.annotation.Aspect
import org.aspectj.lang.annotation.Before
import org.springframework.beans.factory.getBean
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.EnableAspectJAutoProxy
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

fun main() {

    val context = AnnotationConfigApplicationContext()
    context.register(
        AppConfig::class.java,
        SpringData.UserProxy1::class.java,
        SpringData.UserProxy2::class.java,
        SpringData.User::class.java
    )
    context.refresh()
    val bean = context.getBean<SpringData.User>()
    bean.add()
    context.close()
}

@Configuration
@EnableAspectJAutoProxy
open class AppConfig

class SpringData {

    @Component
    open class User {
        open fun add() {
            println("add")
        }
    }

    @Order(2)
    @Aspect
    @Component
    class UserProxy1 {
        @Before("execution(* SpringData\$User.add())")
        fun before() {
            println("before 01")
        }
    }

    @Order(1)
    @Aspect
    @Component
    class UserProxy2 {
        @Before("execution(* SpringData\$User.add())")
        fun before() {
            println("before 02")
        }
    }
}
```

### Spring Data

#### Jdbc Template

##### 简单的添加、更新、删除、查询

```sql
create table t_book
(
    t_id   int(20)     not null primary key auto_increment,
    t_name varchar(20) not null ,
    t_size int         not null
) charset='utf8' collate = 'utf8_bin';
```

```kotlin
    implementation("org.mariadb.jdbc:mariadb-java-client:2.7.3")
    implementation("org.springframework:spring-jdbc:5.3.9")
    implementation("org.springframework:spring-tx:5.3.9")
    implementation("com.alibaba:druid:1.2.6")
    implementation("org.springframework:spring-orm:5.3.9")
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
    <bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource" destroy-method="close">
        <property name="url" value="jdbc:mariadb://localhost:3306/test"/>
        <property name="username" value="test"/>
        <property name="password" value="test"/>
        <property name="driverClassName" value="org.mariadb.jdbc.Driver"/>
    </bean>
    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
        <property name="dataSource" ref="dataSource"/>
    </bean>
</beans>

```

```kotlin
package test

import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.Configuration
import org.springframework.jdbc.core.DataClassRowMapper
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Repository
import org.springframework.stereotype.Service
import javax.annotation.Resource
import kotlin.system.exitProcess

fun main() {
    val context = AnnotationConfigApplicationContext()
    context.register(AppConfig::class.java)
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring.xml")
    context.refresh()
    val bean = context.getBean(BookService::class.java)
    bean.clear()
    bean.addBook(Book(0, "first", 10))
    bean.addBook(Book(0, "first", 10))
    bean.addBook(Book(10, "第10本", 10))
    val book = Book(15, "第15本", 10)
    bean.addBook(book)
    bean.updateBook(book)
    bean.deleteBook(book)
    println(bean.size())
    println(bean.getBookById(10))
    println(bean.getBooksByName("first"))
    context.close()
    exitProcess(0)
}

@ComponentScan("test")
@Configuration
open class AppConfig

@Service
class BookService {
    @Resource
    private lateinit var bookDao: BookDao
    fun addBook(book: Book) {
        bookDao.add(book)
    }

    fun updateBook(book: Book) {
        bookDao.update(book)
    }

    fun deleteBook(book: Book) {
        bookDao.delete(book)
    }

    fun size() = bookDao.length()
    fun clear() {
        bookDao.clear()
    }

    fun getBookById(i: Int): Book {
        return bookDao.getById(i)
    }

    fun getBooksByName(name: String): List<Book> {
        return bookDao.getAllByName(name)
    }
}

interface BookDao {
    fun add(book: Book)
    fun update(book: Book)
    fun delete(book: Book)
    fun length(): Int
    fun clear()
    fun getById(id: Int): Book
    fun getAllByName(name: String): List<Book>
}

@Repository
class BookDaoImpl : BookDao {
    @Resource(name = "jdbcTemplate")
    private lateinit var jdbcTemplate: JdbcTemplate

    override fun getAllByName(name: String): List<Book> {
        return jdbcTemplate.query(
            "select t_id id,t_name name,t_size size from t_book where t_name = ?",
            DataClassRowMapper(Book::class.java),
            name
        )
    }

    override fun getById(id: Int): Book {
        return jdbcTemplate.queryForObject(
            "select t_id id,t_name name,t_size size from t_book where t_id = ?",
            DataClassRowMapper(Book::class.java),
            id
        )!!
    }

    override fun clear() {
        jdbcTemplate.update("delete from t_book")
    }

    override fun length(): Int {
        return jdbcTemplate.queryForObject("select count(*) from t_book", Int::class.java)!!
    }

    override fun add(book: Book) {
        jdbcTemplate.update(
            "insert into t_book(t_id,t_name, t_size) values (?,?,?)",
            book.id, book.name, book.size
        )
    }

    override fun update(book: Book) {
        jdbcTemplate.update(
            "update t_book set t_name=?,t_size=? where t_id=?",
            book.name, book.size, book.id
        )
    }

    override fun delete(book: Book) {
        jdbcTemplate.update("delete from t_book where t_id = ?", book.id)
    }
}

data class Book(
    var id: Int,
    var name: String,
    var size: Int
)


```

##### 批量的添加、更新、删除

```kotlin
package test

import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.Configuration
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Repository
import javax.annotation.Resource
import kotlin.system.exitProcess

fun main() {
    val context = AnnotationConfigApplicationContext()
    context.register(AppConfig::class.java)
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring.xml")
    context.refresh()
    val dao = context.getBean(BookDao::class.java)
    dao.clear()
    dao.batchAdd(
        listOf(
            Book(1, "add0", 10),
            Book(2, "add1", 10),
            Book(3, "add2", 10),
            Book(4, "add3", 10),
        )
    )
    dao.batchUpdate(
        listOf(
            Book(2, "update1", 10),
            Book(3, "update2", 10),
            Book(4, "update3", 10),
        )
    )
    dao.batchDelete( 2, 3)
    context.close()
    exitProcess(0)
}

@Repository
class BookDao {
    @Resource(name = "jdbcTemplate")
    private lateinit var jdbcTemplate: JdbcTemplate

    fun clear() {
        jdbcTemplate.update("delete from t_book")
    }

    fun batchAdd(books: List<Book>) {
        val array = books.map { arrayOf(it.id, it.name, it.size) }.toList()
        jdbcTemplate.batchUpdate("insert into t_book (t_id,t_name, t_size) values (?,?,?)", array)
    }

    fun batchUpdate(books: List<Book>) {
        val array = books.map { arrayOf(it.name, it.size, it.id) }.toList()
        jdbcTemplate.batchUpdate("update t_book set t_name = ?,t_size = ? where t_id = ?", array)
    }

    fun batchDelete(vararg ids: Int) {
        jdbcTemplate.batchUpdate("delete from t_book where t_id = ?", ids.map { arrayOf(it) })
    }
}

data class Book(
    var id: Int,
    var name: String,
    var size: Int
)

@ComponentScan("test")
@Configuration
open class AppConfig

```

#### 事务

特性：（ACID）

- 原子性
- 一致性
- 隔离性
- 持久性

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx.xsd">
    <bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource" destroy-method="close">
        <property name="url" value="jdbc:mariadb://localhost:3306/test"/>
        <property name="username" value="test"/>
        <property name="password" value="test"/>
        <property name="driverClassName" value="org.mariadb.jdbc.Driver"/>
    </bean>
    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>
    <tx:annotation-driven transaction-manager="transactionManager"/>

</beans>

```

```kotlin
package test

import org.springframework.beans.factory.xml.XmlBeanDefinitionReader
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.Configuration
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.stereotype.Component
import org.springframework.stereotype.Repository
import org.springframework.stereotype.Service
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.annotation.Transactional
import javax.annotation.Resource
import kotlin.system.exitProcess

fun main() {
    val context = AnnotationConfigApplicationContext()
    context.register(AppConfig::class.java)
    XmlBeanDefinitionReader(context).loadBeanDefinitions("/spring.xml")
    context.refresh()
    val service = context.getBean(BankService::class.java)
    service.initService()
    service.updateMoney()
    context.close()
    exitProcess(0)
}

@Transactional
@Service()
open class BankService {
    @Resource
    private lateinit var dao: BankDao
    open fun initService() {
        dao.clear()
        dao.add(Bank(1, "dragon", 100))
        dao.add(Bank(2, "guest", 0))
    }

    open fun updateMoney() {
        dao.updateMoney(1,-100)
        1/0
        dao.updateMoney(2,100)
    }
}

@Repository
class BankDao {
    @Resource(name = "jdbcTemplate")
    private lateinit var jdbcTemplate: JdbcTemplate

    fun clear() {
        jdbcTemplate.update("delete from t_bank")
    }

    fun add(bank: Bank) {
        jdbcTemplate.update("insert into t_bank(t_id, t_name, t_money) value (?,?,?)", bank.id, bank.name, bank.money)
    }

    fun updateMoney(id: Int, size: Int) {
        jdbcTemplate.update(
            "update t_bank set t_money = t_money + ? where t_id = ?", size, id
        )
    }
}

data class Bank(
    var id: Int,
    var name: String,
    var money: Int
)

@ComponentScan("test")
@Configuration
open class AppConfig
```

#### 声明式事务管理

```kotlin
@Transactional(
    propagation = Propagation.REQUIRED, // 传播行为
    isolation = Isolation.REPEATABLE_READ, // 隔离级别
    timeout = -1, // 事务超时时间
    readOnly = false, // 是否只能查询
//    rollbackFor =
//    noRollbackFor =
)
```

##### XML声明式事务管理

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:tx="http://www.springframework.org/schema/tx"
       xmlns:aop="http://www.springframework.org/schema/aop"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd
       http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx.xsd">
    <bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource" destroy-method="close">
        <property name="url" value="jdbc:mariadb://localhost:3306/test"/>
        <property name="username" value="test"/>
        <property name="password" value="test"/>
        <property name="driverClassName" value="org.mariadb.jdbc.Driver"/>
    </bean>
    <bean id="jdbcTemplate" class="org.springframework.jdbc.core.JdbcTemplate">
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>
    <tx:advice id="advice">
        <tx:attributes>
            <tx:method name="*"/>
        </tx:attributes>
    </tx:advice>
    <aop:config>
        <aop:pointcut id="pt" expression="execution(* test.BankService.*(..))"/>
        <aop:advisor advice-ref="advice" pointcut-ref="pt"/>
    </aop:config>
</beans>

```

##### 完全注解事务操作

```kotlin
package test

import com.alibaba.druid.pool.DruidDataSource
import org.springframework.context.annotation.AnnotationConfigApplicationContext
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.ComponentScan
import org.springframework.context.annotation.Configuration
import org.springframework.jdbc.core.JdbcTemplate
import org.springframework.jdbc.datasource.DataSourceTransactionManager
import org.springframework.stereotype.Repository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.EnableTransactionManagement
import org.springframework.transaction.annotation.Transactional
import javax.annotation.Resource
import kotlin.system.exitProcess

fun main() {
    val context = AnnotationConfigApplicationContext()
    context.register(AppConfig::class.java)
    context.refresh()
    val service = context.getBean(BankService::class.java)
    service.initService()
    service.updateMoney()
    context.close()
    exitProcess(0)
}

@Transactional
@Service
open class BankService {
    @Resource
    private lateinit var dao: BankDao
    open fun initService() {
        dao.clear()
        dao.add(Bank(1, "dragon", 100))
        dao.add(Bank(2, "guest", 0))
    }

    open fun updateMoney() {
        dao.updateMoney(1, -100)
        1 / 0
        dao.updateMoney(2, 100)
    }
}

@Repository
class BankDao {
    @Resource()
    private lateinit var jdbcTemplate: JdbcTemplate

    fun clear() {
        jdbcTemplate.update("delete from t_bank")
    }

    fun add(bank: Bank) {
        jdbcTemplate.update("insert into t_bank(t_id, t_name, t_money) value (?,?,?)", bank.id, bank.name, bank.money)
    }

    fun updateMoney(id: Int, size: Int) {
        jdbcTemplate.update(
            "update t_bank set t_money = t_money + ? where t_id = ?", size, id
        )
    }
}

data class Bank(
    var id: Int,
    var name: String,
    var money: Int
)

@EnableTransactionManagement
@ComponentScan("test")
@Configuration
open class AppConfig {
    @Bean
    open fun getDataSource(): DruidDataSource {
        return DruidDataSource().run {
            url = "jdbc:mariadb://localhost:3306/test"
            username = "test"
            password = "test"
            driverClassName = "org.mariadb.jdbc.Driver"
            this
        }
    }

    @Bean
    open fun getJdbcTemplate(ds: DruidDataSource): JdbcTemplate = JdbcTemplate().run {
        dataSource = ds
        this
    }

    @Bean
    open fun getDataSourceTransactionManager(ds: DruidDataSource): DataSourceTransactionManager =
        DataSourceTransactionManager().run {
            dataSource = ds
            this
        }
}
```