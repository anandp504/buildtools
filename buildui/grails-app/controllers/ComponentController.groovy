import com.tumri.buildtools.*;
            
class ComponentController {
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    def allowedMethods = [delete:'POST', save:'POST', update:'POST']
    
    def beforeInterceptor = [action:this.&checkUser]
    
        def checkUser = {
             if(!session.email) {
                session.r = ['action':actionName, 'controller':controllerName, 'id':params.id]
                redirect(controller:'user',action:'login')
                return false
             }
    }

    def list = {
        if(!params.max) params.max = 10
        [ componentList: Component.list( params ) ]
    }

    def show = {
        def component = Component.get( params.id )

        if(!component) {
            flash.message = "Component not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ component : component ] }
    }

    def delete = {
        def component = Component.get( params.id )
        if(component) {
            component.delete()
            flash.message = "Component ${params.id} deleted"
            redirect(action:list)
        }
        else {
            flash.message = "Component not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def component = Component.get( params.id )

        if(!component) {
            flash.message = "Component not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ component : component ]
        }
    }

    def update = {
        def component = Component.get( params.id )
        if(component) {
            component.properties = params
            if(!component.hasErrors() && component.save()) {
                flash.message = "Component ${params.id} updated"
                redirect(action:show,id:component.id)
            }
            else {
                render(view:'edit',model:[component:component])
            }
        }
        else {
            flash.message = "Component not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def component = new Component()
        component.properties = params
        return ['component':component]
    }

    def save = {
        def component = new Component(params)
        def branch = new Branch()
        branch.component = component;
        branch.name = "main"
        branch.path = params.mainBranch
        branch.stagedir = "" 
        branch.releasedir = "" 

        if(!component.hasErrors() && !branch.hasErrors() &&
            component.save() && branch.save()) {
            flash.message = "Component ${component.id} created"
            redirect(action:show,id:component.id)
        }
        else {
            render(view:'create',model:[component:component])
        } 
    }
    def displaylog = {
      def displaylogCommand = new DisplaylogCommand()
      displaylogCommand.exec()
      if (!displaylogCommand.getSuccess()) {
        flash.message = displaylogCommand.getError()
        render(view:'displaylog',model:[log:""])
      } else
        render(view:'displaylog',model:[log:displaylogCommand.getLog()])
    }

    def clean = {
      def cleanCommand = new CleanCommand()
      cleanCommand.exec()
      if (!cleanCommand.getSuccess()) {
        flash.message = cleanCommand.getError()
        render(view:'displaylog',model:[log:""])
      } else
        render(view:'displaylog',model:[log:"Build workspace has been cleaned."])
    }
}
