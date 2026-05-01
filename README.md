\# DiagnosticTools



> Простые диагностические утилиты для Windows. Для тех, кто не хочет запоминать 10 команд.



Альфа. Работает 2 функции из 5 запланированных. Тестируйте, ругайтесь, подсказывайте.







\## Установка





Install-Module Diager -Scope CurrentUser


(в консоль PowerShell)




Что умеет сейчас

1\. Get-DiskStress — всё о дисках

Свободное место 



Здоровье диска (Healthy / не Healthy)



Дефрагментация: SSD скажет «не надо», HDD покажет команду для ручного запуска





Get-DiskStress          # показать всё

Get-DiskStress -free    # только свободное место

Get-DiskStress -health  # только здоровье

Get-DiskStress -dn      # только анализ дефрагментации



2\. Get-ServStatus — главные службы

Проверяет 7 ключевых служб:



Файрвол (mpssvc)



Защитник Windows (WinDefend)



Центр обновлений (wuauserv)



Служба времени (w32time)



Аудио (audiosrv)



IPSec (PolicyAgent)



Центр безопасности (wscsvc)







Что планируется 

Get-CpuLoad — нагрузка по ядрам



Get-RamStatus — оперативка и страничный файл



Get-NetDiagnostic — пинг и потеря пакетов





Пример вывода (в консоли подсвечивается цветами)



Diager >>> \[GETTING]: Your disks free space...

Diager >>> \[GOT]: Your disks free space

Diager >>> \[OK]: C: free space is normal. It's 234.5 GB

Diager >>> \[WARNING]: Less than 5GB free space on D: disk!



Diager >>> \[GETTING]: Your services status...

Diager >>> \[GOT]: Your services status

Diager >>> Firewall service is Running

Diager >>> Windows Defender service is Running



Как я это писал

Я учу PowerShell неделю. Это мой первый осмысленный код.

Код рабочий, но есть куда расти. Вот что меня самого бесит и я хочу исправить:



Write-Host вместо объектов — норм? Или переделывать под профессионалов?



Get-ServStatus проверяет только 7 служб — какие ещё добавить?



Буду благодарен, если напишете совет или вопрос.

Telegram: @rightround0

Почта: alsllale@mail.ru

GitHub Issues: https://github.com/mmischab1999-sketch/diager/issues/new



Лицензия

MIT — можно копировать, менять, использовать в своих проектах. Просто упомяните автора.







