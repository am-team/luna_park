# Сущность (Entity)
Класс _Сущность_ отвечает какой-то реальный объект. Это может быть договор, стул, агент недвижимости, пирог, утюг, кот, холодильник - всё что угодоно. Любой объект который  может вам понадобиться для моделирования ваших бизнес-процессов - это _Сущность_.
Понятие _Сущности_ по Эвансу и по Мартину отличаются. С точки зреня Эванса, сущность - это объект, харакреризующаяся чем-то, что подчекркивает ее индивидуальнсть.
<spoiler title='Сущность по Звансу'>

> Если объект определяется уникальным индивидуальным существованием, а не набором атрибутов, это свойство следует с читать главным при определении объекта в модели . Определение класса должно быть простым и строиться вокруг непрерывности и уникальности цикла существования объекта. Найдите способ различать каждый объект независимо от его формы или истории существования. С особым вниманием отнеситесь к техническим требованиям, связанным с сопоставлением объектов по их атрибутам. Задайте операцию , которая бы обязательно давала неповторимый результат для каждого такого объекта, - возможно, для этого с объектом придется ассоциировать некий символ с гарантированной уникальностью . Такое средство идентификации может иметь внешнее происхождение, но это может быть и произвольный идентификатор, сгенерированный системой для ее собственного удобства. Однако такое средство должно соответствовать правилам различения объектов в модели. В модели должно даваться точное определение, что такое одинаковые объекты.

</spoiler>

С точки зрения Мартина, _Entity_ -  это не объект а слой. Этот слой объединят как объект так и бизнес-логику по его изменению.

<spoiler title="Разъеснение от Мартина">

>  My view of Entities is that they contain Application Independent Business rules.  They are not simply data objects.  They may hold references to data objects; but their purpose is to implement business rule methods that can be used by many different applications.

> Gateways return Entities.  The implementation (below the line) fetches the data from the database, and uses it to construct data structures which are then passed to the Entities.  This can be done either with containment or inheritance.
>
> For example:
>
> public class MyEntity { private MyDataStructure data;}
>
> or
>
> public class MyEntity extends MyDataStructure {...}
>
> And remember, we are all pirates by nature; and the rules I'm talking about here are really more like guidelines...

</spoiler>

Мы под _Сущностью_ будем иметь в виду только структуру. В простейшем варианте класс _Entity_ будет выглядеть так:

```ruby
module Entities
  class MeatBag < LunaPark::Entites::Simple
    attr_accessor :id, :name, :hegiht, :weight, :birthday
  end
end
```
Мутабельный объект, описывающий структуры бизнес модели. Может содержать примитивные типы и _Значения_.
Класс [`LunaPark::Entites::Simple`]() невероятно прост, вы можете посмотреть его код, он дает нам только одну вещь - простую инициализацию.

Вы можете написать:

```ruby
john_doe = Entity::MeatBag.new(
  id:        42,
  name:     'John Doe',
  height:   '180cm',
  weight:   '80kg',
  birthday: '01-01-1970'
)
```
Как вы уже наверное догадались вес, рост и дату рождения мы захотим обернуть в _Объекты-значения_.
```ruby
module Entities
  class MeatBag < LunaPark::Entites::Simple    
    attr_accessor :id, :name
    attr_reader   :heiht, :wight, :birthday
    
    def height=(height)
        @height = Values::Height.wrap(height)
    end
    def weight=(height)
        @height = Values::Weight.wrap(weight)
    end
    def birthday=(day)
      @birthday = Date.parse(day)
    end   
  end
end
```
Чтобы не использовать каждый раз подобные сложные конструкторы, у нас подготовлена более сложная _Реализация_ :  

```ruby
module Entities
  class MeatBag < LunaPark::Entites::Nested
    attr_accessor :id, :name

    attr :heiht,    Values::Height, :wrap
    attr :weight,   Values::Weight, :wrap
    attr :birthday, Values::Date,   :parse
  end
end
```

Данная реализация основана на основе [WrapperStruct]() . Как можно догадаться из названия данная _Реализация_ позволяет делать древовидные структуры.

Давайте удовлетворим мою страсть к крупной бытовой технике. В прошлой статье мы проводили аналогию между ["крутилкой" стиральной машины и архитектурой](https://habr.com/post/429750). А сейчас мы опишем такой важный бизнес - объект как холодильник:

![Refregerator](https://habrastorage.org/webt/xl/65/pj/xl65pjsr5ou5a4nurhdm9qxbo50.png)

```ruby
class Refregerator < LunaPark::Entites::Nested
  attr_accessor :id, :brand, :title
  
  namespace :fridge do
    namespace :door do
    	attr :upper, Shelf, :wrap
    	attr :lower, Shelf, :wrap  
    end
    attr :upper, Shelf, :wrap
    attr :lower, Shelf, :wrap
  end
  
  namespace :main do
    namespace :door do
    	attr :first,  Shelf, :wrap
    	attr :second, Shelf, :wrap  
      attr :third,  Shelf, :wrap
    end
    
    namespace :boxes do
  		attr :left,  Box, :wrap
    	attr :right, Box, :wrap
    end
    
    attr :first,  Shelf, :wrap
    attr :second, Shelf, :wrap  
    attr :third,  Shelf, :wrap
    attr :fourth, Shelf, :wrap
  end
  
  attr_accessor :last_open_at, comparable: false
end	 
```

Такой подход избавляет нас от создания ненужных _Сущностный_, таких как дверь от холодильника, вне от холодильника. 

У класса `LunaPark::Entites::Nested` есть еще 2 важных свойства:

Сравниваемость:

```ruby
module Entites
	class User < LunaPark::Entites::Nested
  	attr :email
  	attr :registred_at
	end
end

u1 = Entites::User.new(email: 'john.doe@mail.com', created_at: Time.now)
u2 = Entites::User.new(email: 'john.doe@mail.com', created_at: Time.now)

u1 == u2 # => false
```

Два указанных пользователя не эквивалентны, т.к. они были созданы в разное время и поэтому значение атрибута `registred_at` будет отличаться. Но если мы вычеркнем атрибут из списка сравниваемых:

```ruby
module Entites
	class User < LunaPark::Entites::Nested
  	attr :email
  	attr :registred_at, comparable: false
	end
end
```

То получим два сопоставимых объекта. Эта _Реализация_ так же обладает свойством оборачиваемости - мы можем использовать метод  класса`wrap`:

```ruby
Entites::User.wrap(email: 'john.doe@mail.com', created_at: Time.now)
```

Вы можете использовать в качестве _Entity_ - Hash, OpenStruct, или любой понравившийся вам gem, который поможет вам реализовать структуру вашей сущности. _Сущность_ - это модель бизнес объекта, не пытайтесь описать те свойства присуще реальному объекту но бесполезны в бизнесе.