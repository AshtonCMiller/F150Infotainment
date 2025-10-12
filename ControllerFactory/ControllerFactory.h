#pragma once

#include <QObject>
#include <QMap>
#include <QString>
#include <functional>

// Define proper import/export macros
#if defined(CONTROLLERFACTORY_LIBRARY)
#  define CONTROLLERFACTORY_EXPORT Q_DECL_EXPORT
#else
#  define CONTROLLERFACTORY_EXPORT Q_DECL_IMPORT
#endif

class CONTROLLERFACTORY_EXPORT ControllerFactory
{
public:
    using CreatorFunc = std::function<QObject*(QObject*)>;

    static ControllerFactory& instance();

    void registerClass(const QString& name, CreatorFunc func);
    QObject* create(const QString& name, QObject* parent = nullptr);

private:
    QMap<QString, CreatorFunc> m_creators;
};
