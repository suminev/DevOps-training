# DevOps-training

https://devops.sumlab.ru

Этот репозиторий я создавал после дедлайна, но здесь как таковой автоматизации нет. Есть только сборка образа докера, настрока nginx и мои шаги по ручному развёртыванию.

<h2>Запуск приложения</h2>
1. Сперва изучил --help. Узнал про дефолтные настройки.<br>
2. С помощью отладчика gdb увидел ошибку с отстутствующим файлом конфигурации. Создал этот файл и добавил в него дефолный конфиг.<br>
3. Запустил локально БД PostgreSQl<br>
4. Перенастроил дефолтный конфиг. И запустил сервер командой bingo run_server.<br>
5. Узнал номер процесса приложения и с помощью команды sudo lsof -p посмотрел, какой порт слушает приложение. Через браузер достучался до него. В моем случае был 29637 порт.<br>

<h2>Создание Docker-образа</h2>
1. Когда приложение запустилось, решил создать образ.<br>
2. Для нового образа использовал базовый образ alpine. Поскольку он более легковесный, по сравнению с другими.<br>
3. Подготовил файловую структуру /opt, которая нужна приложению для работы. Положил в неё конфиг и файл для логов.<br>
4. Указал в Dockerfile создать нового пользователя, создать директорию для bingo, полностью скопировать структуру opt, выдать на новые директории права доступа от нового пользователя, переключиться на этого пользователя и запустить от его имени приложение. Запустил сборку.<br>
5. При запуске контейнера указывал проброс портов:<br>
docker run -it --rm --name app-bingo -p 29637:29637 bingo:v1<br>

<h2>Настройка облака</h2>
1. Судя по ТЗ, две ноды должно было быть под само приложение. Про остальную инфраструктуру сказано не было. В чате также ясного ответа не нашёл. Поэтому решил использовать следующую схему:<br>
* две ВМ под bingo. Объединил их в одну Instance Groups. Добавил их в целевую группу и подключил балансировщик;<br>
* одну ВМ под PostgreSQl;<br>
* одну ВМ под nginx;<br>
2. Запросы приходят на nginx, дальше пересылаются на балансировщик, который распределяет их по ВМ с приложением. Сами приложения уже связываются с PostgreSQl.<br>

<h2>Настройка Nginx</h2>
1. Nginx работает в качестве обратного прокси сервера.<br>
2. Сейчас на нём настроено:<br>
* подключение домена;<br>
* отключение кэширования для большинства запросов;<br>
* отправка запросов на балансировщик;<br>
* настройка ssl-сертификата;<br>
* для /api/session и /api/customer настроена длительное ожидание ответа;<br>
* для /long_dummy настроено кэширование, чуть меньше минуты. Когда указал минуту, то тест не проходил проверку.<br>

<h2>Настройка ВМ с контейнерами bingo</h2>
1. Для автоматического перезапуска ВМ в группе, они должны быть описаны каким-то шаблоном. Здесь у меня было несколько вариантов:<br>
* Описать шаблон ВМ с первоначальными настройками через cloud-init. Но как я ни пытался, запустить контейнер через cloud-init у меня не получилось. С другуми командами проблем не возникало. Образ использовал Container Optimized Image 2.3.10, у него докер уже установлен. Пришлось отказаться.<br>
* Хотел запустить контейнер с помощью Container Solution. Но не нашёл возможности запустить контейнер с пробросом портов. Запускал в базовой настройке и достучаться до приложения не получалось. Также, у меня не сработало описание через Docker-compose. Хоть там и можно было указать порт, но в итоге доступ так и не появился. От этого варианта тоже отказался.<br>
* Следующий вариант был рабочий. Настроил группу с помощью спецификации yaml, через cli. Там можно указать порт, параметры ВМ и другие настройки.<br> 
* Ещё один рабочий вариант, который у меня был. Создать ВМ, настроить её, скачать docker-образ и запустить его с автоматическим перезапуском (--restart always). Потом остановить её и создать образ диска. На основе этого образа подготовить шаблон. Этот вариант был у меня реализован первым.<br>
2. На автотестах разницы между двумя рабочими вариантами не было. Поэтому я остановился на первом, с помощью автоматического перезапуска. Также, со вторым вариантом не нашёл способ, как указать при создании группы виртуальных машин автоматически создавать и целевую группу. А если создавать целевую группу вручную, то нет возможности добавить в неё группу машина, а только выборочно. Если ВМ пересоздастся, то её уже не будет в целевой группе.<br>  

<h2>Некоторые комментарии</h2>
1. Запускал запись tcpdump на nginx-сервере во время автотестов. Удалось записать 150мб данных. Из того, что мне удалось интересного обнаружить - это запрос /500. На который приложение отвечает "You asked for 500".<br>
2. После дедлайна в чате обсуждали логи приложения. Про них я как-то благополучно забыл. Мне показалось, что работа с приложение ограничивается его запуском и связкой с БД, а всё остальное это уже от инфраструктуры зависит.<br>
3. У bingo есть команда ./bingo completion bash, которая должна генерировать файл для автодополнения. Сам файл получилось достать. Дальше пытался добиться от него каких-то результатов, даже получилось его скормить консоли, но ничего толком не вышло.<br>
