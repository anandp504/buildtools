            
class BranchController {
    
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
          //params.component = Component.get(params.id)
          //return [ branchList: Branch.findAll("from Branch as b where b.component=:component",params);
          return [ branchList: Branch.list( params ) ]
    }

    def show = {
        def branch = Branch.get( params.id )

        if(!branch) {
            flash.message = "Branch not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ branch : branch ] }
    }

    def delete = {
        def branch = Branch.get( params.id )
        if(branch) {
            branch.delete()
            flash.message = "Branch ${params.id} deleted"
            redirect(action:list)
        }
        else {
            flash.message = "Branch not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def branch = Branch.get( params.id )

        if(!branch) {
            flash.message = "Branch not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ branch : branch ]
        }
    }

    def update = {
        def branch = Branch.get( params.id )
        if(branch) {
            branch.properties = params
            if(!branch.hasErrors() && branch.save()) {
                flash.message = "Branch ${params.id} updated"
                redirect(action:show,id:branch.id)
            }
            else {
                render(view:'edit',model:[branch:branch])
            }
        }
        else {
            flash.message = "Branch not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def component = Component.get( params.id )
        def branch = new Branch()
        branch.properties = params
        return ['branch':branch, 'component' : component]
    }

    def save = {
        def component = Component.get( params.component.id )
        def branch = new Branch(params)
        if(!branch.hasErrors() && branch.save()) {
            flash.message = "Branch ${branch.id} created"
            redirect(action:show,id:branch.id)
        }
        else {
            render(view:'create',model:[branch:branch, component:component])
        }
    }
}