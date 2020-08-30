# Платформа

## База данных 

### Описание

### Абстракция представления данных в системе

Данные в системе представлены в виде объектов и имеют слой абстракции описание которого изложено ниже.

#### Слой абстракции
* Это логическая модель и способ хранения данных в СУБД. Суть которой заключается в том, что единицей хранения данных в системе является не запись в конкретной таблице, а **объект** или по другому - **документ**.     

#### Определение объекта 
* **_Объект_** - это физическая или логическая сущность, которую можно представить в виде единого целого. Клиент - это объект, договор - это объект и даже адрес клиента также можно представить в виде объекта.

* _Объект_ обладает рядом характеристик, таких как: «**_класс_**», «**_тип_**» и «**_состояние_**». Объект в системе разделён на два базовых класса - **_документ_** и **_справочник_**.

* _Документ_ имеет поле `area` (зона). **Зона** ограничивает область видимости документа. **_Справочник_** не обладает таким свойством.

* Над _объектом_ можно совершать «_действия_», которые вызывают в системе «_события_», которые, в свою очередь, могут привести к изменению «_состояния_» объекта. Всё это является механизмом работы _документооборота_.

#### Документооборот
Это последовательность совершаемых над объектом действий, приводящих к возникновению событий, способных повлиять на состояние объекта. Последовательность переходов из одного состояния объекта в другое называется «`жизненным циклом`».

#### Сущность
* Характеризует физический или логический смысл _объекта_.

**Сущность** задаётся разработчиком системы и в отличие от других характеристик объекта не может быть изменена пользователем системы. На данный момент системе определены следующие сущности:
- `object` Объект;
- `document` Документ;
- `reference` Справочник;
- `address` Адрес;
- `client` Клиент;
- `calendar` Календарь;
- `...` Что-то ещё.

#### Класс
* Это условное разделение объекта по тем или иным признакам.

Класс объекта характеризует сам объект. Класс объекта в отличие от сущности может быть создан пользователем системы по его собственному усмотрению.

Классы объекта создаются в виде дерева, т.е. имеют иерархическую структуру. Для каждого класса объекта настраиваются своя собственная схема документооборота, т.е. формируется список, в каких именно состояниях может находиться объект. Для каждого состояния создается список доступных действий, для каждого действия создается список событий и настраивается таблица переходов из одного состояния в другое т.е. «_жизненный цикл_».

Класс объекта может быть _абстрактным_, создать документ с абстрактным классом объекта невозможно.

##### Дерево классов объекта
- `object` Объект (абстрактный);
  - `document` Документ (абстрактный);
    - `address` Адрес;
    - `client` Клиент;
    - `...` Что-то ещё;
  - `reference` Справочник (абстрактный);
    - `calendar` Календарь рабочих дней;
    - `...` Что-то ещё.

#### Состояния
* Каждый объект в системе находиться в том или ином состоянии. _Состояние_ объекта привязывается к классу объекта. Список состояний для каждого класса объектов индивидуален и может быть настроен пользователем по своему собственному усмотрению.

##### Тип состояния объекта
В системе есть четыре типа состояния объекта:
- `created` Создан;
- `enabled` Включен;
- `disabled` Отключен;
- `deleted` Удалён.

##### Состояние объекта
* Это промежуточное звено в цепи документооборота системы.

Каждому из типов состояния должно соответствовать как минимум одно состояние объекта из чего следует, что каждый объект может находиться как минимум в четырех состояниях. Типы состояний объекта недоступны для изменения пользователю системы, но на базе этих типов пользователь может создать сколько угодно собственных состояний объекта. Первоначальное состояние любого нового объекта в системе это – «Создан». Для каждого состояния объекта задается определенный список действий. Переход из одного состояния объекта в другое происходить только при совершении над ним определенного действия.

#### Действие
* Действие, совершаемое над объектом также, как и состояния объекта задается для каждого класса объекта и формируется из заданного разработчиком системы списка..

На основе заданных действий, путем добавления новых или переопределения уже имеющихся, для каждого класса, пользователь системы может сформировать свой собственный список **_методов_** и **_событий_**.
 
#### Метод (динамический)
* Это визуальная часть в цепи документооборота системы.

Именно методы отображаются в интерфейсе пользователя в виде кнопок и элементов меню.

#### Событие
* Это реакция на совершаемое над объектом действие.

К каждому событию объекта привязывается написанные на языке PL/pgSQL процедуры. При возникновении события ядро системы начинает поочередно выполнять код в привязанных к событию процедурах. Выполняемый код может быть абсолютно любым, и иметь разную смысловую нагрузку будь то проверка объекта на переход из одного состояния в другое или информирование пользователя о неправильно заполненных полях.

Переход объекта из одного состояния в другое, согласно настроенного документооборота, происходит при вызове функции `ChangeObjectState()`.

Для того, чтобы совершить действие над объектом (_включить_, _выключить_, _удалить_, _уничтожить_) необходимо вызвать функцию `ExecuteObjectAction(pObject, pAction)`.
