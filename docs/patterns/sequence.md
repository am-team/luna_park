# Последовательность действий (Sequence)

Каждый бизнес процесс можно описать при момощи последовательности действий.

Паттерн _Последовательность_ отвечает за:
- Последовательность выполнения _Действий_.
- Координацию передаваемых данных между _Действиями_.
- Обработку ошибок совершаемых _Дейсвтиями_ во время их выполнения.
- Возвращение результа совокупности совершенных _Действий_.
- __ВАЖНО__ Самое главная ответственность этого паттерна это реализация доменного уровня. 
 
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
         
      def call!
        Services::CheckProductsAvailability.call        list: ingredients
        dough   = Services::BeatDough.call              from: Repository::Products.get(beat_ingredients)
        filler  = Services::MakeСabbageFiller.call      from: Repository::Products.get(filler_ingredients)
        pie     = Services::MakePie.call                dough, with: filler
        bake    = Services::BakePie.new                 pie,   temp: TEMPERATURE
        sleep 5.min until bake.call
      end
      
      private
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

Как мы видем метод `call!` описывает всю бизнесс логику (БЛ) процесса выпечки пирога. И его удобно использовать для понимания
и описания доменного уровня.

Так же мы лего можем описать процесс выпечки рыбного пирога, заменив `MakeСabbageFiller` на `MakeFishFiller`.
Тем самым мы очень быстро меняем бизенс процесс, без существенных доработок кода. И также мы можем оставить
обе `Последовательности` одновременно, масштабируя бизнес кейсы.  

### Договоренности

- Метод `call!` является единственным обязательным публичным методом, он описывает порядок действий. 
- Остальные методы наследуемого от класса `LunaPark::Sequence` должны быть приватными
- Метод `returned_data` является обязательным приватным методом, он описывает возвращаемый результат.
- Каждый параметр инициализации должен описываться чере сеттер  или `attr_acessor`:
```ruby
module Foo
  # ...
  private
  attr_accessor :bar 
end

Service::Foo.call(bar: 42)
```
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
```ruby
# bad - не пишите вызов каждого сервайса в отдельном методе
#       Это делает код более раздутым. Приходится просматривать весь 
#       класс несколько раз, чтобы понять как он работает.
  
module Service
  class CookingPieWithСabbage < LunaPark::Sequence
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

# good - используйте вызов действий прямо в класе
class DrivingStart < LunaPark::Sequence
  def call!
    Service::CheckEngine.call
    Service::StartUpTheIgnition.call car, with: key
    Service::ChangeGear.call         car.gear_box, to: :drive
    Service::StepOnTheGas.call       car.pedals[:right]
  end
end
```

### 2. Если нужно используйте циклы

```ruby
# bad - описывать каждое действие отдельной строкой
module JesusLife
  module Sequences
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
    module Sequences
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