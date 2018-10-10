# Действие (Service)

Действие является простым в реализации паттерном, но не смотря на это он
выполняет одну из самых важных функций приложения - реализацию исполнения 
одного действия внутри бизес процессов.

Рассмотрим простой пример из жизни, нам захотелось попить молока из холодильника.

Итак у нас есть Бизнес процесс `Попить молочка из холодильника`.

Давайте попробуем его декомпозировать.

- Открываем холодильник
- Проверяем налчие молока
- Берем молоко
- Закрываем холодильник
- Наливаем молоко в стакан
- Пьем молоко

Каждое такое действтие можено реализовать через Service Object.

## Реализация

```ruby
# ./app/boundeded_context/services/drink_milk.rb

module BoundedContext
  module Services
    class DrinkMilk < LunaPark::Service
    
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
