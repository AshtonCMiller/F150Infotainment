#pragma once
#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QVariantList>
#include <QQmlApplicationEngine>

class AppManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList apps READ apps NOTIFY appsChanged)

public:
    explicit AppManager(QQmlApplicationEngine* engine, QObject *parent = nullptr);
    QVariantList apps() const { return m_apps; }

    void initializeControllers(); // Initialize controllers before loading them
    void loadControllers(); // Load controllers at startup
    QObject* controller(const QString& name) const;

    Q_INVOKABLE QVariantMap getApp(int index) const;
    Q_INVOKABLE void reloadApps();

signals:
    void appsChanged();

private:
    QVariantList m_apps;
    QQmlApplicationEngine* m_engine;
    QMap<QString, QObject*> m_controllers;
    void loadApps();
};
