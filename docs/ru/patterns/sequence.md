# Последовательность действий (Sequence)

Каждый бизнес процесс можно орписать при момощи последовательности действий.

Паттерн _Последовательность_ отвечает за:
- Последовательность выполнения _Действий_.
- Координацию передаваемых данных между _Действиями_.
- Обработку ошибок совершаемых _Дейсвтиями_ во время их выполнения.
- Возвращение результа совокупности совершенных _Действий_.
- __ВАЖНО__ Самое главная олтветственность этого паттерна это реализация доменного уровня. 
 
На последней ответственности хотелось бы остановиться подробнее, если у нас имеется какой-то сложный 
процесс - мы должны описать его так, чтобы было понтяно, что происходит не вдаваясь в технические детали.
Лучшей практикой будет считаться если вы начнете описывать свой функционал непосредственно с класса 
_Sequence_. А позже вдаваться в техническую реализацию. Так же как и начинание любого дела лучше начать с его 
плана.
 
Как мы это сделаем? 

Рассмотрим действительно сложный бизнес процесс: `Приготовление пирога с капустой`.

Давайте попробуем его декомпозировать.

- Проверить наличие продуктов
- Взять их со склада
- Замесить тесто
- Дать тесту поднятся
- Подготовить начинку
- Сделать пирог
- Испечь пирог 

Давайте попробуем описать доменную логику через _Sequence_.

## Реализация

```ruby
# ./app/boundeded_context/services/drink_milk.rb

module Kitchen
  module Sequences
    class CookingPieWithСabbage < LunaPark::Sequence
      TEMPERATURE = Values::Temperature(180, unit: :cel)
    
      attr_accessor :beat_ingredients, :filler_ingredients
      
      def call!
        Services::CheckProductsAvailability.call        list: ingredients
        dough   = Services::BeatDough.call              from: Repository::Products.get(beat_ingredients)
        filler  = Services::MakeСabbageFiller.call      from: Repository::Products.get(filler_ingredients)
        pie     = Services::MakePie.call                dough, with: filler
        bake    = Services::BakePie.new                 pie,   temp: TEMPERATURE
        sleep 5.min until bake.call
      end
      
      def returned_data
        pie
      end
      
      private
      
      attr_accessor :pie
      
      def ingredients_list
        beat_ingredients_list + filler_ingredients_list
      end
    end
  end  
end
```

Как мы видем метод `call!` описывает всю БЛ, процесса выпечки пирога. И его удобно использовать для понимания
и описания доменного уровня.

Так же мы лего можем описать процесс выпечки рыбного пирога, заменив `MakeСabbageFiller` на `MakeFishFiller`.
Тем самым мы очень быстро меняем бизенс процесс, без существенных доработок кода. И также мы можем оставить
обе `Последовательности` одновременно, масштабируя бизнес кейсы.  

### Договорености

- Метод `call!` является обязательным публичным методом, он описывает порядок действий. 
- Метод `returned_data` является обязательным публичным методом, он описывает возвращаемый результат.
- Каждый параметр инициализации должен описываться чере сеттер  или `attr_acessor`.
- Остальные методы должны быть приватными
- Метод `call!` может возвращать объект.

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

cooking = Kitchen::Sequences::CookingPieWithСabbage.call(
  beat_ingredients:   beat_ingredients, 
  filler_ingredients: filler_ingredients
)

````

В случае успеха:
```
cooking.success?     => true
cooking.fail         => false
cooking.fail_message => ''
cooking.data         => Entity::Pie
```

Если пирог сгорел:
```
cooking.success?     => false
cooking.fail         => true
cooking.fail_message => 'The pie burned out'
cooking.data         => nil
```


## Обработка ошибок

Как нам уследить за пирогом? Для этого определим ошибку `Burned` в _Действие_ `BakePie`. 

```ruby

module Kitchen
  module Errors
    class Burned < LunaPark::Errors::Processing; end
  end
end

module Kitchen
  module Services < LunaPark::Service
    class BakePie    
      def call
          # ...
          rescue Errors::Burned, 'The pie burned out' if pie.burned?
          # ...
      end    
    end
  end
end
````

Тогда сработает перехватчик ошибок, и мы сможем разобраться с ними в `Эндпоинтах`. 
Ошибки не унаследованные от `Processing` будут востприматься как системные, и будут перехватываться на урове 
Сервера, и если не обозначенные другие условия пользователь получит 500 Server Error.

## Практика использования

### 1. Старайтесь описывать все вызовы в call! 

Это делает код более компактным. Не нужно метаться по всему классу чтобы понять как он работает. 

__BAD__
```ruby
module Service
  class CookingPieWithСabbage < LunaPark::Sequence
    def call!
      check_products_availability
      make_cabbage_filler
      make_pie
      bake
    end
    
    def check_products_availability
      Services::CheckProductsAvailability.call list: ingredients  
    end

    # ...
  end
end

```

__GOOD__

Класс описанный в основном примере.

### 2. Используйте в название действия глагол действия в форме Present Continuous и объект воздействия.
                                                                       .

__BAD__
```ruby
module Services
  class Making; end 
  class UserBuilding; end
  class PasswordGenerating; end
  class BuildСonstruction; end
end
```
__GOOD__
```ruby
module Services
  class MakingNewOrder; end 
  class BuildingUser; end 
  class GeneratingPassword; end
  class BuildingСonstruction; end
end
```

### 3. По возможности используйте метод класса call

Обычно экземпляр класса _Действия_, редко используется кроме того, чтобы писать сделать вызов.

Логично использовать сокращенную запись.

__GOOD__
```ruby 
Sequence::RingingToPerson.call(params)
```   

Тем не менее, есть возможность создавать экземпляр объекта _Действия_, 
что может быть полезно, когда нам нужно переиспользовать его, с учетом внутреннего состояния.

```ruby 
ring = Sequence::RingingToPerson.new(person)

unless ring.success?
  ring.call
  sleep 5.min
end
```   

### 4. Испольузуйте именнованную переменную в initializer'e когда это уместно

__GOOD__
```ruby
class ProcessingFoo 
  def initialize(foo)
  end
end
```

__BAD__
```ruby
class ProcessingFoo 
  def initialize(param1:, param2:)
  end
end

```
__GOOD__
```ruby
class ProcessingFoo 
  def initialize(foo, param1:, param:)
  end
end
```

### 5. Не создавайте _Действия_ ради типизации кода, смотрите по ситуации

__BAD__

```ruby
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
```

__GOOD__

```ruby
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


