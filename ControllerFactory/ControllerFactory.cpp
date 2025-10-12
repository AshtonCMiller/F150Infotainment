#include "ControllerFactory.h"

ControllerFactory& ControllerFactory::instance()
{
    static ControllerFactory inst;
    return inst;
}

void ControllerFactory::registerClass(const QString& name, CreatorFunc func)
{
    m_creators[name] = func;
}

QObject* ControllerFactory::create(const QString& name, QObject* parent)
{
    auto it = m_creators.find(name);
    if (it != m_creators.end())
        return it.value()(parent);
    return nullptr;
}
