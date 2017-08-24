﻿///////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды sync
//
// Представляет собой модификацию приложения gitsync от 
// команды oscript-library
//
// Структура модуля реализована в соответствии с рекомендациями 
// oscript-app-template (C) EvilBeaver
//
///////////////////////////////////////////////////////////////////

Перем Лог;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт

	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Выполняет синхронизацию хранилища 1С с git-репозиторием (указание имени команды необязательно)");
	
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ПутьКХранилищу", "Файловый путь к каталогу хранилища конфигурации 1С.");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "URLРепозитория", "Адрес удаленного репозитория GIT.");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ЛокальныйКаталогГит", "Каталог исходников внутри локальной копии git-репозитария.");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-email", "<домен почты для пользователей git>");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-v8version", "<Маска версии платформы (8.3, 8.3.5, 8.3.6.2299 и т.п.)>");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-debug", "<on|off>");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-verbose", "<on|off>");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-branch", "<имя ветки git>");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-format", "<hierarchical|plain>");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-tempdir", "<Путь к каталогу временных файлов>");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-push-every-n-commits", "<число> количество коммитов до промежуточной отправки на удаленный сервер");
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, "-amount-look-for-license", "<число> количество повторов получения лицензии (попытка подключения каждые 10 сек), 0 - без ограничений");
	Парсер.ДобавитьПараметрФлагКоманды       (ОписаниеКоманды, "-process-fatform-modules", "Переименовывать модули обычных форм в Module.bsl");	
	Парсер.ДобавитьПараметрФлагКоманды       (ОписаниеКоманды, "-stop-if-empty-comment", "Остановить, если Комментарий к версии пустой");
	Парсер.ДобавитьПараметрФлагКоманды		 (ОписаниеКоманды, "-auto-set-tags", "Автоматическая установка тэгов по версия конфиграции");

	Парсер.ДобавитьКоманду(ОписаниеКоманды);

	// для использования по умолчанию
	Парсер.ДобавитьПараметр("ПутьКХранилищу", "Файловый путь к каталогу хранилища конфигурации 1С.");
	Парсер.ДобавитьПараметр("URLРепозитория", "Адрес удаленного репозитория GIT.");
	Парсер.ДобавитьПараметр("ЛокальныйКаталогГит", "Каталог исходников внутри локальной копии git-репозитария.");

	Парсер.ДобавитьИменованныйПараметр("-email", "<домен почты для пользователей git>");
	Парсер.ДобавитьИменованныйПараметр("-v8version", "<Маска версии платформы (8.3, 8.3.5, 8.3.6.2299 и т.п.)>");
	Парсер.ДобавитьИменованныйПараметр("-debug", "<on|off>");
	Парсер.ДобавитьИменованныйПараметр("-verbose", "<on|off>");
	Парсер.ДобавитьИменованныйПараметр("-branch", "<имя ветки git>");
	Парсер.ДобавитьИменованныйПараметр("-format", "<hierarchical|plain>");
	Парсер.ДобавитьИменованныйПараметр("-tempdir", "<Путь к каталогу временных файлов>");
	Парсер.ДобавитьИменованныйПараметр("-push-every-n-commits", "<число> количество коммитов до промежуточной отправки на удаленный сервер");
	Парсер.ДобавитьПараметрФлаг       ("-process-fatform-modules", "Переименовывать модули обычных форм в Module.bsl");

	Парсер.ДобавитьПараметрФлагКоманды("-stop-if-empty-comment", "Остановить, если Комментарий к версии пустой");
	Парсер.ДобавитьПараметрФлагКоманды("-auto-set-tags", "Автоматическая установка тэгов по версия конфиграции");

КонецПроцедуры // ЗарегистрироватьКоманду

Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач ДополнительныеПараметры) Экспорт

	Лог = ДополнительныеПараметры.Лог;
	Лог.Информация("Начинаю синхронизацию хранилища 1С и репозитария GIT");

	ПутьКХранилищу			= ПараметрыКоманды["ПутьКХранилищу"];
	URLРепозитория			= ПараметрыКоманды["URLРепозитория"];
	ЛокальныйКаталогГит		= ПараметрыКоманды["ЛокальныйКаталогГит"];
	ДоменПочты				= ПараметрыКоманды["-email"];
	ВерсияПлатформы			= ПараметрыКоманды["-v8version"];
	НачальнаяВерсия			= ПараметрыКоманды["-minversion"];
	КонечнаяВерсия			= ПараметрыКоманды["-maxversion"];
	Формат					= ПараметрыКоманды["-format"];
	ИмяВетки				= ПараметрыКоманды["-branch"];
	Лимит					= ПараметрыКоманды["-limit"];
	КоличествоКоммитовДоPush = ПараметрыКоманды["-push-every-n-commits"];
	ПереименовыватьФайлМодуляОбычнойФормы = ПараметрыКоманды["-process-fatform-modules"];
	ПрерватьВыполнениеБезКомментарияКВерсии = ПараметрыКоманды["-stop-if-empty-comment"];
	АвтоматическаяУстановкаТэговПоВерсиям = ПараметрыКоманды["-auto-set-tags"];

	Если НачальнаяВерсия = Неопределено Тогда

		НачальнаяВерсия = 0;

	КонецЕсли;

	Если КонечнаяВерсия = Неопределено Тогда

		КонечнаяВерсия = 0;

	КонецЕсли;

	Если Лимит = Неопределено Тогда

		Лимит = 0;

	КонецЕсли;
	
	Если КоличествоКоммитовДоPush = Неопределено Тогда

		КоличествоКоммитовДоPush = 0;

	КонецЕсли;

	Если ПрерватьВыполнениеБезКомментарияКВерсии = Неопределено Тогда

		ПрерватьВыполнениеБезКомментарияКВерсии = Ложь;

	КонецЕсли;

	Если АвтоматическаяУстановкаТэговПоВерсиям = Неопределено Тогда

		АвтоматическаяУстановкаТэговПоВерсиям = Ложь;

	КонецЕсли;

	НачальнаяВерсия = Число(НачальнаяВерсия);
	КонечнаяВерсия = Число(КонечнаяВерсия);
	Лимит = Число(Лимит);
	КоличествоКоммитовДоPush = Число(КоличествоКоммитовДоPush);

	Если ЛокальныйКаталогГит = Неопределено Тогда

		ЛокальныйКаталогГит = ТекущийКаталог();

	КонецЕсли;

	Если Формат = Неопределено Тогда

		Формат = РежимВыгрузкиФайлов.Авто;

	КонецЕсли;

	Если ИмяВетки = Неопределено Тогда

		ИмяВетки = "master";

	КонецЕсли;

	Лог.Отладка("ПутьКХранилищу = " + ПутьКХранилищу);
	Лог.Отладка("URLРепозитория = " + URLРепозитория);
	Лог.Отладка("ЛокальныйКаталогГит = " + ЛокальныйКаталогГит);
	Лог.Отладка("ДоменПочты = " + ДоменПочты);
	Лог.Отладка("ВерсияПлатформы = " + ВерсияПлатформы);
	Лог.Отладка("Формат = " + Формат);
	Лог.Отладка("ИмяВетки = " + ИмяВетки);
	Лог.Отладка("НачальнаяВерсия = " + НачальнаяВерсия);
	Лог.Отладка("КонечнаяВерсия = " + КонечнаяВерсия);
	Лог.Отладка("Лимит = " + Лимит);
	Лог.Отладка("КоличествоКоммитовДоPush = " + КоличествоКоммитовДоPush);
	
	Распаковщик = РаспаковщикКонфигурации.ПолучитьРаспаковщик(ДополнительныеПараметры);
	Распаковщик.ВерсияПлатформы = ВерсияПлатформы;
	Распаковщик.ДоменПочтыДляGitПоУмолчанию = ДоменПочты;
	Распаковщик.ПереименовыватьФайлМодуляОбычнойФормы = ПереименовыватьФайлМодуляОбычнойФормы;

	Лог.Информация("Получение изменений с удаленного узла (pull)");
	КодВозврата = Распаковщик.ВыполнитьGitPull(ЛокальныйКаталогГит, URLРепозитория, ИмяВетки);
	Если КодВозврата <> 0 Тогда
		
		ВызватьИсключение "Не удалось получить изменения с удаленного узла (код: " + КодВозврата + ")";

	КонецЕсли;

	Лог.Информация("Синхронизация изменений с хранилищем");
	РаспаковщикКонфигурации.ВыполнитьЭкспортИсходников(Распаковщик, 
							ПутьКХранилищу, 
							ЛокальныйКаталогГит, 
							НачальнаяВерсия, 
							КонечнаяВерсия, 
							Формат, 
							КоличествоКоммитовДоPush, 
							URLРепозитория,
							Лимит,
							ПрерватьВыполнениеБезКомментарияКВерсии,
							ИмяВетки,
							АвтоматическаяУстановкаТэговПоВерсиям);

	Лог.Информация("Отправка изменений на удаленный узел");
	КодВозврата = Распаковщик.ВыполнитьGitPush(ЛокальныйКаталогГит, URLРепозитория, ИмяВетки, АвтоматическаяУстановкаТэговПоВерсиям);
	Если КодВозврата <> 0 Тогда
		ВызватьИсключение "Не удалось отправить изменения на удаленный узел (код: " + КодВозврата + ")";
	КонецЕсли;

	Лог.Информация("Синхронизация завершена");

	Возврат МенеджерКомандПриложения.РезультатыКоманд().Успех;

КонецФункции // ВыполнитьКоманду