# Домашнее задание к занятию "11.01 Введение в микросервисы"

## Задача 1: Интернет Магазин

Руководство крупного интернет магазина у которого постоянно растёт пользовательская база и количество заказов рассматривает возможность переделки своей внутренней ИТ системы на основе микросервисов. 

Вас пригласили в качестве консультанта для оценки целесообразности перехода на микросервисную архитектуру. 

Опишите какие выгоды может получить компания от перехода на микросервисную архитектуру и какие проблемы необходимо будет решить в первую очередь.

---
## Решение

Выгода:
* Возможность использовать разные технологии - полезная вещь, которая позволит не только не зависить от конкретных решений, но и иметь возможность всегда внедрять лучшие практики, способные значительно улучшить качество работы;
* Масштабируемость - надежды на геометрический рост продаж - желание каждого магазина. Масштабируемость позволит увеличивать ресурсы при необходимости для того, чтобы отвечать на вызовы роста числа обращений к компонентам магазина;
* Простота развёртывания и администрирования- большая часть всех сервисов уже есть в докер образах, поэтому развернуть и администрировать каждый сервис проще, т.к. он работает в изолированной и независимой среде, что исключает влияение смежных сервисов на него; Также данный пункт  позволит более быстро внедрять обновления и откатывать систему в случае ошибок. 
* Простота замены - при необходимости обновить и\или вывести компонент из эксплуатации сделать это в микросервисной архитектуре значительно проще. Это минимизирует простои и делает бизнес более доступным;


Однако, прежде чем приступить к внедрению микросервисов необходимо решить ряд вопросов:
* Нарастить компетенции команды и выстроить бизнес процессы таким  образом, чтобы микросервисная архитектура не была целью, а лишь инструментом, позволяющим улучшить разные аспекты ведения бизнеса;
* Выбрать технологический стек, с которым компания начнёт разработку и согласовать API;
* Необходимо привести к актуальному состоянию документацию - это нужно на любом этапе и в значительной степени улучшит качество ведения бизнеса со стороны IT;
* Наладить взамодействие внутри команд разработчиков и поддержки для лучшего взаимодействия между командами;

Решив все вопросы, а также перейдя на архитектуру микросервисов, бизнес сможет получить значительное преимущество. 


---
