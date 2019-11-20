# Прикладное и системное программирование

Ключевой частью разработки вашего приложения станет описание бизнес логики. Для коммерческих приложений эта часть является самой сложной. И сложность ее заключается в нахождении простого решения. Нужно понимать что в программировании есть различные задачи. Задачи прикладного и системного программирования отличаются. Прежде всего по назначению: 
 прикладной программист пишет приложения, которые используются бизнесом, людьми, потребителями, теми самыми пользователями о которых мы постоянно говорим. Системные программисты пишут код для системы, или технических специалистов. И именно назначение является ключевым в выборе применяемых решений.
 
Датчик температуры предназначен для отображения температуры и никакой самый прогрессивный маркетолог не сможет заставить его показывать уровень сахара в крови, потому что этого хочет рынок. Программное обсечение такого датчика должно работать корректно и потреблять мало ресурсов. И именно малое количество ресурсов делает эту задачу сложной, а найденные решения порой вообще за гранью понимания. Подобные решения из сферы космических технологий выглядят действительно впечатляющими. И многие малоопытные разработчики или преподаватели, которые посвятили свое время теоретическим знаниям берут системные решения за образец.

Молодой падаван ведомый любовью к компьютерным играм и романтикой голубого свечения ЭЛТ монитора, поступает в технический ВУЗ. Там его обучают математике и C++, его хвалят за победы в олимпиадах и нахождения нестандартных решений. Все это на самом деле здорово, ровно до того момента, как молодой специалист находит свою первую работу в интернет магазине. Там молодой специалист начинает применять свои знания на практике. Задачи он решает, все довольны, бизнес растет и его назначают техдиром. Вера в гениальность усиливается, почти бог. Ну если не бог, то вождь небольшого племени точно.

Все это хорошо работает пока он один. Нет ни чего хуже системного программиста-самоучки занимающегося коммерческой разработкой. Задача системного программиста - написать оптимальный код. Задача прикладного программиста - написать код понятный. Хороший прикладной программист не создает техническое решение, а улучшает текущие процессы компании, за счет автоматизации и осознанного подхода.

Каждый из нас должен понимать чем он на самом деле занимается и выбирать правильные инструменты для своей работы.

В прошлой главе мы рассмотрели инструменты которые позволяют нам хранить состояние объектов. В этой мы рассмотрим те, которые позволят изменить это состояние. 


# Действие (Action)

Если говорить о классическом понимании, *Сценарий использования (UseCase)* - это список *Действий* или шагов событий, определяющих  взаимодействие между ролью (Actor) и системой для достижения цели. Мы можем считать, что *Сценарий использования* - реализует тот или иной бизнес-процесс.

*Действие* является простым в реализации шаблоном, но не смотря на это он выполняет одну из самых важных функций приложения -реализацию исполнения одного шага внутри бизнес-процессов.

Рассмотрим простой пример из жизни, нам захотелось попить молока из холодильника.

Итак у нас есть Последовательность действий `Попить молочка из холодильника`.

Давайте попробуем его декомпозировать.

- Открываем холодильник
- Проверяем наличие молока
- Берем молоко
- Закрываем холодильник
- Наливаем молоко в стакан
- Пьем молоко

Каждое такое действие можно реализовать через сценарий напишем ServiceObject.

## Реализация

```ruby
module KorovaMilkBar
  module Services
    class DrinkMilk
    
      DEFAULT_GULP_SIZE = Values::Volume.new(10, unit: 'ml')
      
      def initializer(milk_customer:, glass:)
        @milk_customer = milk_customer
        @glass         = glass
      end
      
      def call
        until glass.empty? do
          gulp = Values::Milk.new(size: gulp_size)
          glass.volume = glass.content - gulp
          milk_customer.stomach << gulp
        end
      end
      
      private
      attr_reader :milk_customer, :glass
      
      def gulp_size
        milk_customer.mouth.volume || DEFAULT_GULP_SIZE
      end
    end
  end  
end
```

Если мы описываем бизнес логику, мы употребляем термин *Действие*, его можно реализовать, простым методом. Или через функциональный объект, давайте рассмотрим, что это такое.

## Функциональные объекты
В самом примитивном виде функциональный объект имеет один единственный публичный метод - `call`.

```ruby
class Sum
  def initialize(x, y)
    @x = x
    @y = y
  end
  
	def call
		x + y
  end  
    
  def self.call(x,y)
    new(x,y).call
  end
  
  private
  attr_reader :x, :y
end
```

Такие объекты имеют ряд преимуществ. Они лаконичны, их очень просто тестировать. Есть и недостаток, таких объектов может получиться большое количество. Эрик Эванс решает это за счет того, что объединяет ряд функций в один объект. Представим, что нам нужно смоделировать бизнес-процессы няни Арины Радиновны - она может кормить Пушкина и  укладывать его спать:
```ruby
class NoonService
  def initialize(arina_radionovna, pushkin)
    # ...
  end

	def to_feed
		# ...
	end
	
	def to_sleep
		# ...
	end
end
```
Такой подход более корректный с точки зрения ООП. Но мы предлагаем от него отказаться, по крайне мере, на начальных этапах. Не очень опытные программисты начинают писать много кода в таком классе, что в конечном счете переводит к увеличению связанности.

Использовать класс можно так:
```ruby
x = Sum.new(2,3).call
```
При таком вызове нам приходится создавать объект а потом запускать его обработку, чтобы сократить количество кода, мы напишем одноименный метод класса:

```ruby
  def self.call(x,y)
    new(x,y).call
  end
```

Теперь мы можем посчитать сумму так:
```ruby
x = Sum.call(2,3)
x = Sum.(2,3) # или даже так
```

Но что должен возвращать метод *call*?

Тут все зависит от того, какую реализацию *Действия* мы выберем. Вспомним картинку которую я приводил в одной из предыдущих статей:
![Processing](https://habrastorage.org/webt/of/hk/al/ofhkalijd4o2u3xrwtptgtzjko0.png)

В своей архитектуре мы используем *UseCase* как уровень и он представлен рядом похожих шаблонов проектирования.

## Сервисный Объект (Service)
В нашей реализации Service - выполняет одно Действие и всегда возвращает значение.

```ruby
module KorovaMilkBar
  module Services
  	class FindMilk < LunaPark::UseCases::Serivce
  	  GLASS = Values::Unit.wrap '200g'
  	
  	  def initialize(fridge:)
  	    @fridge = fridge
	  end
	  
	  private
	  attr_reader :fridge
	  
	  def execute
	  	fridge.shelfs.find { |shelf| shelf.has?(GLASS, of: :milk) }
	  end
  	end
  end
end	
```


У нас был метод call, причем тут execute? Давайте рассмотрим следующий пример.

## Команда (Command)
В нашей реализации Service - выполняет одно Действие изменяет объект, в случае успеха возвращает true.


```ruby
module KorovaMilkBar
  module Commands
  	class FindMilk < LunaPark::UseCases::Command
  	  GLASS = Values::Unit.wrap '200g'
  	
  	  def initialize(fridge:)
  	    @fridge = fridge
	  end
	  
	  private
	  attr_reader :fridge
	  
	  def execute
	  	fridge.shelfs.find { |shelf| shelf.has?(GLASS, of: :milk) }
	  end
  	end
  end
end	
```




### Договорености

- Метод `call` является едиственным обязательным публичным методом.
- Метод `initialize` является единственным опциональным публичным методом.
- Остальные методы должны быть приватными
- Метод `call` может возвращать объект.
- Логические ошибки произошедшие в результате _Действия_ должны наследоваться от 
класса `LunaPark::Service::Erros::Processing` 


## Обработка ошибок

Следует разделить 2 типа ошибок которые могут проихойти во время работы того или иного _Действия_.


##### Ошибки процесса выполнения
Такие ошибки могу возникать в результате нарушения логики обработки.

Например:
- При создании пользователя email зарезервирован
- При поптыке выпить молока оно закончилось
- Другой микросервис отклонил действие

По всей вероятности об этих ошибках захочет узнать пользователь. Так же вероятнее эти те ошибки 
которые мы можем предвидеть.

Такие ошибки дожны наследоваться от ```LunaPark::Service::Erros::Processing```


#####  Системный ошики
Ошибки которые произошли в результате сбоя системы

Например:
- Не работает БД

По всей вероятности мы не можем предвидеть эти ошибки, и ничего не можем сказать пользователю кроме
 того, что все очень плохо.  

Такие ошибки дожны наследоваться от ```SystemError```

__GOOD__

```ruby
module Services
  class CheckEmailIsUniq
    module Errors
      class EmailIsNotUniq < LunaPark::Service::Erros::Processing; end
    end
    
    FAIL_MESSAGE = 'Email is not uniq'
      
    def initialize(email)
      @email = email
    end
    
    def call
      raise Errors::EmailIsNotUniq.new(FAIL_MESSAGE) if Repository::User.find_by(email: email) 
    end
    
    private
    attr_reader :email
  end
end
```

## Практика использования

### 1. Передавайте в сервайс объекты а не параметры 

Старайтесь делать инициализатор _Действия_ простым, если обработка параметров не является его целью.
Передавайте в ему объекты, а не параметры. 

__BAD__
```ruby
module Service
  class Foo 
    def initialize(foo_params:, bar_params:)
      @foo = Values::Foo.new(*foo_params)
      @bar = Values::Bar.new(*bar_params)
    end
    
    def call
      # ...
    end
    
    private 
    
    attr_accessor :foo, :bar
  end
end

Services::Foo.call(foo: {a: 1, b: 2}, bar: 34)

```

__GOOD__
```ruby
module Services
  class Foo 
    def initialize(foo:, bar:)
      @foo = foo
      @bar = bar
          
      private
      
      attr_reader :foo, :bar
    end
  end
end

foo = Values::Foo.new(a: 1, b: 2)
bar = Values::Foo.new(34)
Services::Foo.call(foo: foo, bar: bar)

```
Логичным исключением явется реализация `Builder`'а.

__GOOD__
```ruby
module Service
  class BuildFoo 
    def initialize(param_1:, param_2:)
      @param_1 = param_1
      @param_1 = param_1
    end
    
    def call
      Foo.new(
        param_1: param_1,
        param_2: param_2,
        param_3: some_magick
      ) 
    end
        
    private
      
    attr_reader :param_1, :param_1
    
    def some_magick
      # ...
    end
  end
end
```

### 2. Используйте в название действия глагол действия и объект воздействия.

__BAD__
```ruby
module Services
  class Milk; end 
  class Work; end 
  class FooBuild; end
  class PasswordGenerator; end
end
```
__GOOD__
```ruby
module Services
  class GetMilk; end 
  class WorkOnTable; end 
  class BuildFoo; end
  class GeneratePassword; end
end
```

### 3. По возможности используйте метод класса call

Обычно экземпляр класса _Действия_, редко используется кроме того, чтобы писать сделать вызов.

Логично использовать сокращенную запись.

__GOOD__
```ruby 
Services::BuildFoo.call(params)
```   

Тем не менее, есть возможность создавать экземпляр объекта _Действия_, 
что может быть полезно, когда нам нужно переиспользовать его, с учетом внутреннего состояния.

```ruby 
ring = Services::RingToPhone.new(phone: neighbour)
10.times do
  ring.call
end
```   

### 4. Испольузуйте именнованную переменную в initializer'e когда это уместно

__GOOD__
```ruby
class ProcessFoo 
  def initialize(foo)
  end
end
```

__BAD__
```ruby
class BuildFoo 
  def initialize(param1:, param2:)
  end
end

```
__GOOD__
```ruby
class BuildFoo 
  def initialize(foo, param1:, param:)
  end
end
```

### Обработка ошибок не явяляется задачей сервиса

__BAD__
```ruby
def call
  
  #...
rescue SystemError => e
  return false
end
``` 


# Последовательность действий (Interactor)

Каждый бизнес процесс можно описать при помощи последовательности действий.

Шаблон проектирования _Последовательность_ отвечает за:
- Последовательность выполнения _Действий_.
- Координацию передаваемых данных между _Действиями_.
- Обработку ошибок совершаемых _Действиями_ во время их выполнения.
- Возвращение результата совокупности совершенных _Действий_.
- __ВАЖНО__ Самое главная ответственность этого партерна это реализация бизнес логики. 
 
На последней ответственности хотелось бы остановиться подробнее, если у нас имеется какой-то сложный процесс - мы должны описать его так, чтобы было понятно, что происходит не вдаваясь в технические детали.
Лучшей практикой будет считаться если вы начнете описывать свой функционал непосредственно с класса _Interactor_. А позже вдаваться в техническую реализацию. Так же как и начинание любого дела лучше начать с его плана.
 
Как мы это сделаем? 

Рассмотрим действительно сложный бизнес процесс: `Приготовление пирога с капустой`.

Давайте попробуем его декомпозировать.

- Проверить наличие продуктов
- Взять их со склада
- Замесить тесто
- Дать тесту подняться
- Подготовить начинку
- Сделать пирог
- Испечь пирог 

Давайте попробуем описать доменную логику через _Interactor_.

## Реализация

```ruby
module Kitchen
  module Sequences
    class CookingPieWithСabbage < LunaPark::Interactors::Sequence
      TEMPERATURE = Values::Temperature.new(180, unit: :cel)
      
      private
         
      def execute
        Services::CheckProductsAvailability.call        list: ingredients
        dough   = Services::BeatDough.call              from: Repository::Products.get(beat_ingredients)
        filler  = Services::MakeСabbageFiller.call      from: Repository::Products.get(filler_ingredients)
        pie     = Services::MakePie.call                dough, with: filler
        bake    = Services::BakePie.new                 pie,   temp: TEMPERATURE
        sleep 5.min until bake.call
      end
      
      
      attr_accessor :beat_ingredients, :filler_ingredients
      attr_accessor :pie
      
      def returned_data
        pie
      end
      
      def ingredients_list
        beat_ingredients_list + filler_ingredients_list
      end
    end
  end  
end
```

Как мы видим метод `call!` описывает всю бизнес логику (БЛ) процесса выпечки пирога. И его удобно использовать для понимания
и описания доменного уровня.

Так же мы легко можем описать процесс выпечки рыбного пирога, заменив `MakeСabbageFiller` на `MakeFishFiller`.
Тем самым мы очень быстро меняем бизнес-процесс, без существенных доработок кода. И также мы можем оставить
обе `Последовательности` одновременно, масштабируя бизнес кейсы.  

### Договоренности

- Метод `execute` является обязательным методом, он описывает порядок действий.
- Метод `returned_data` является обязательным приватным методом, он описывает возвращаемый результат.
- Каждый параметр инициализации должен описываться через сеттер  или `attr_acessor`:

```ruby
module Foo
  # ...
  private
  attr_accessor :bar 
end

Service::Foo.call(bar: 42)
```
- Остальные методы должны быть приватными

## Пример использования

```ruby
beat_ingredients = [
  Entity::Product.new :flour,   500, :gr,
  Entity::Product.new :oil,     50,  :gr,
  Entity::Product.new :salt,    1,   :spoon,
  Entity::Product.new :milk,    150, :ml,
  Entity::Product.new :egg,     1,   :unit,
  Entity::Product.new :yeast,   1,   :spoon
]

filler_ingredients = [
  Entity::Product.new :cabbage, 500, :gr,
  Entity::Product.new :salt,    1,   :spoon,
  Entity::Product.new :pepper,  1,   :spoon
]

cooking = CookingPieWithСabbage.call(
  beat_ingredients:   beat_ingredients, 
  filler_ingredients: filler_ingredients
)

```

В случае успеха:
```ruby
cooking.success?     => true
cooking.fail         => false
cooking.fail_message => ''
cooking.data         => Entity::Pie
```

Если пирог сгорел:
```ruby
cooking.success?     => false
cooking.fail         => true
cooking.fail_message => 'The pie burned out'
cooking.data         => nil
```


## Обработка ошибок

`Interactor` перехватывает все ошибки унаследованные от класса `LunaPark::Errors::Processing`. 

Как нам уследить за пирогом? Для этого определим ошибку `Burned` в _Действие_ `BakePie`. 

```ruby
module Kitchen
  module Errors
    class Burned < LunaPark::Errors::Processing; end
  end
end
```

И, во время выпечки, проверим, что наш пирог не сгорел.

```
module Kitchen
  module Services 
    class BakePie < LunaPark::UseCases::Service   
      def call
          # ...
          rescue Errors::Burned, 'The pie burned out' if pie.burned?
          # ...
      end    
    end
  end
end
```

Тогда сработает перехватчик ошибок, и мы сможем разобраться с ними в `Эндпоинтах`. 
Ошибки не унаследованные от `Processing` будут восприниматься как системные, и будут перехватываться на уровне сервера, и если не обозначенные другие условия пользователь получит 500 ServerError.


## Практика использования


### 1. Старайтесь описывать все вызовы в execute

Не пишите вызов каждого UseCase в отдельном методе. Это делает код более раздутым. Приходится просматривать весь класс несколько раз, чтобы понять как он работает. Испортим рецепт выпечки пирога.

```ruby
# BAD
module Service
  class CookingPieWithСabbage < LunaPark::Interactors::Sequence
    def call!
      check_products_availability
      make_cabbage_filler
      make_pie
      bake
    end
    
    # ...
    
    def check_products_availability
      Services::CheckProductsAvailability.call list: ingredients  
    end

    # ...
  end
end
```

Используйте вызов действий прямо в классе. Такой подход с точки зрения ruby может показаться непривычным, но он действительно выглядит более читабельным. 

```ruby
class DrivingStart < LunaPark::Interactors::Sequence
  def call!
    Service::CheckEngine.call
    Service::StartUpTheIgnition.call car, with: key
    Service::ChangeGear.call         car.gear_box, to: :drive
    Service::StepOnTheGas.call       car.pedals[:right]
  end
end
```

### 2. Если нужно используйте циклы

Представим, что вы Иисус и вам потребовалось накормить вином и рыбой 12 апостолов. 

```ruby
# bad - описывать каждое действие отдельной строкой
module JesusLife
  module Interactors
    class FeedingTheApostles
      def call!
        Service::GiveFood.call :fish, to: Repositories::Apostles.get(:pavel)    
        Service::GiveFood.call :wine, to: Repositories::Apostles.get(:pavel)
        # ...    
      end
    end
  end
end

# good - действия повторяются, используйте циклы
 module JesusLife 
    module Interactors
      class FeedingTheApostles
        def call!
          # Iuda dont drink alcohol & he is vegan
          APOSTLES.dup.delete(:iuda).each do |apostle|
            Service::GiveFood.call :fish, to: Repositories::Apostles.get(apostle)
            Service::GiveFood.call :fish, to: Repositories::Apostles.get(apostle)
          end
        end
      end 
    end
end
```

### 3. Используйте в название действия глагол действия в форме Present Continuous и объект воздействия.                                                                     .

```ruby
# bad

module Services
  class Making; end               # Используется только глагол 
  class UserBuilding; end         # Существиельное Глагол
  class PasswordGenerating; end   # Существиельное Глагол
  class BuildСonstruction; end    # Present Simple
end

# good
module Services
  class MakingNewOrder; end 
  class BuildingUser; end 
  class GeneratingPassword; end
  class BuildingСonstruction; end
end
```

### 4. По возможности используйте метод класса call

```ruby
# good - Обычно экземпляр класса _Действия_, редко используется кроме 
#        того, чтобы писать сделать вызов. Логично использовать сокращенную запись.
 
Sequence::RingingToPerson.call(params)

# good - Тем не менее, есть возможность создавать экземпляр объекта _Действия_, 
#         что может быть полезно, когда нам нужно переиспользовать его, с учетом внутреннего состояния.

ring = Sequence::RingingToPerson.new(person)

unless ring.success?
  ring.call
  sleep 5.min
end
```

### 5. Не создавайте _Действия_ ради типизации кода, смотрите по ситуации

```ruby
# bad - мы решили делать всю логику в сервайсах, а чтобы 
#       сделать более легкий sequence

module Services
  class BuildUser< LunaPark::Service
    def initialize(first_name:, last_name:, phone:)
      @first_name = first_name
      @last_name = last_name
      @phone = phone
    end
    
    def call
      Entity::User.new(
        first_name: first_name, 
        last_name: last_name,
        phone: phone 
      )
    end
    
    private
    attr_reader :first_name, :last_name, :phone
  end
end

module Sequences
  class RegisteringUser < LunaPark::Sequence
    attr_accessor :first_name, :last_name, :phone

    def call!
      user = Service::BuildUser.call(first_name: first_name, last_name: last_name, phone: phone)
    end
  end
end


# good - Создание entity,просто в реализации и больше нигде не переиспользуется

module Sequences
  class RegisteringUser < LunaPark::Sequence
    attr_accessor :first_name, :last_name, :phone

    def call!
      user #...
    end
    
    private 
    def user
      @user = Entity::User.new(
        first_name: first_name, 
        last_name: last_name,
        phone: phone 
      )
    end
  end
end
```