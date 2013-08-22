import com.tumri.buildtools.*;
class BuildController {

    private static final String ATTACHDIR = "/opt/Tumri/buildui/data/attachments";

    def testvar;

    def beforeInterceptor = [action:this.&checkUser,except:['getxml']]
   
    def checkUser = {
            if(!session.email) {
               session.r = ['action':actionName, 'controller':controllerName, 'id':params.id]
               redirect(controller:'user',action:'login')
               return false
       }
    }


    private boolean isDir(String path) {
         if ((path != null) && (path.length() > 0)) {
            File f = new File(path);
            if (f != null) {
                 if (f.isDirectory())
                    return true;
                 else 
                    return (f.mkdir());
            }
         }
         return false;
    }
    
    def index = { redirect(action:list,params:params) }

    // the delete, save and update actions only accept POST requests
    def allowedMethods = [delete:'POST', save:'POST', update:'POST']

    def list = {
        def bl
        if(!params.max) params.max = 10
        if(!params.sort) params.sort = "date"
        if(!params.order) params.order = "desc"
        if(params.bid) {
            def b = Branch.get(params.bid);
            bl = b ? Build.findAllByBranch(b, params) : []
        }
        else 
            bl = Build.list( params ) 
        [ buildList: bl, branch: params.bid ]
    }

    def show = {
        def build = Build.get( params.id )
        if(!build) {
            flash.message = "Build not found with id ${params.id}"
            redirect(action:list)
        }
        else { return [ build : build ] }
    }

    def delete = {
        def build = Build.get( params.id )
        if(build) {
              def brid = build.branch.id;
              build.delete()
              flash.message = "Build ${params.id} deleted"
              redirect(action:list, params:['bid':brid])
            }
        else {
            flash.message = "Build not found with id ${params.id}"
            redirect(action:list)
        }
    }

    def edit = {
        def build = Build.get( params.id )

        if(!build) {
            flash.message = "Build not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ build : build ]
        }
    }

    def update = {
        def build = Build.get( params.id )
        if(build) {
            build.properties = params
            if(!build.hasErrors() && build.save()) {
                flash.message = "Build ${params.id} updated"
                redirect(action:show,id:build.id)
            }
            else {
                render(view:'edit',model:[build:build])
            }
        }
        else {
            flash.message = "Build not found with id ${params.id}"
            redirect(action:edit,id:params.id)
        }
    }

    def create = {
        def branch = Branch.get(params.id)
        def build = new Build()
        build.component = branch.component;
        build.properties = params
        return ['build':build, 'branch':branch]
    }

    def getxml = {
       def b = Build.get(params.id);
       if (b) {
            render(contentType: "text/xml") {
                BuildComponent (id: b.id) {
                    BuildData {
                        componentname(b.component.component) 
                        branchname(b.branch.name)
                        depotPath(b.branch.path)
                        version(b.release)
                        base(b.base)
                        tickets(b.tickets)
                        user(b.user)
                        notes(b.notes)
                    }
                    ConfigData {
                        componentType(b.component.type)
                        versionFile(b.component.versionfile)
                        buildDir(b.component.builddir)
                        installDir(b.component.installdir)
                        buildToolsDir(b.component.buildtoolsdir)
                        extDir(b.component.libdir)
                        dirs(b.component.projectdirs)
                        stagingDir(b.branch.stagedir.equals("") ? b.component.stagedir : b.branch.stagedir)
                        releaseDir(b.branch.releasedir.equals("") ? b.component.releasedir : b.branch.releasedir)
                        devbuildDir(b.branch.devbuilddir.equals("") ? b.component.devbuilddir : b.branch.devbuilddir)
                        mailto(b.component.mailto)
                    }
                }
            }       
        }
        else {
            render(contentType: "text/xml") {
                Error {
                    Reason ("build id ${params.id} does not exist")
                }
            } 
        }
    }

    def save = {
        println "Build user is  "+session.email;
        def build = new Build(params)
        build.user = session.email
        build.date = new Date()
        build.component = build.branch.component
        build.stagingUrl = '';
        build.releaseUrl = ''; 
        String attachment = ''; 
        def f = request.getFile("attachedfile");
        if ((f) && (f.getOriginalFilename().size()> 0) && isDir(ATTACHDIR)) {
           f.transferTo(new File(ATTACHDIR+"/"+f.getOriginalFilename())) 
           attachment = "${f.getOriginalFilename()},${f.getContentType()}"
        }
        if(!build.hasErrors() && build.save(flush:true)) {
          def buildCommand = new BuildCommand()
          def id = String.format("%d", build.id)
          buildCommand.setId(id);
          if (attachment.size() > 0)
             buildCommand.setAttachmentInfo(attachment);
          //buildCommand.setComponent(build.component.component)
          //buildCommand.setDepotpath(build.branch.path)
          //buildCommand.setBranchName(build.branch.name)
          //buildCommand.setVersion(build.release)
          //buildCommand.setBase(build.base)
          //buildCommand.setTickets(build.tickets)
          //buildCommand.setUser(session.email)
          //buildCommand.setNotes(build.notes)
          buildCommand.exec();
          if (buildCommand.getSuccess()) {
             build.release = buildCommand.getBuildVersion()
             build.stagingUrl = buildCommand.getStagingUrl()
             build.releaseUrl = buildCommand.getStagingUrl()

             flash.message = "Build ${build.id} created"
             redirect(action:show,id:build.id)
          } else {
             build.delete();
             flash.message = buildCommand.getError()
             render(view:'create',model:[build:build, branch:build.branch])
          }
        }
        else {
            render(view:'create',model:[build:build, branch:build.branch])
        }
    }

    def edit2release = {
        def build = Build.get( params.id )

        if(!build) {
            flash.message = "Build not found with id ${params.id}"
            redirect(action:list)
        }
        else {
            return [ build : build ]
        }
    }

    def release = {
      def build = Build.get( params.id )
      if (! build) {
            flash.message = "Build not found with id ${params.id}"
            redirect(action:list)
      }
      build.properties = params
      build.user = session.email
      def attachment = '';

      def f = request.getFile("attachedfile");
      if ((f) && (f.getOriginalFilename().size()> 0) && isDir(ATTACHDIR)) {
         f.transferTo(new File(ATTACHDIR+"/"+f.getOriginalFilename())) 
         attachment = "${f.getOriginalFilename()},${f.getContentType()}"
      }

      if (build.hasErrors() || (! build.save(flush:true))) {
           flash.message = "Build ${params.id} has errors and/or cannot be saved."
           redirect(action:edit2release,id:build.id)
      }

      def releaseCommand = new ReleaseCommand()
      def id = String.format("%d", build.id)
      releaseCommand.setId(id);
      if (attachment.size() > 0)
         releaseCommand.setAttachmentInfo(attachment);
      //releaseCommand.setComponent(build.component.component)
      //releaseCommand.setDepotpath(build.branch.path)
      //releaseCommand.setBranchName(build.branch.name)
      //releaseCommand.setVersion(build.release)
      //releaseCommand.setNotes(build.notes)
      //releaseCommand.setUser(session.email)
      releaseCommand.exec()
      if (releaseCommand.getSuccess()) {
             build.releaseUrl = releaseCommand.getReleaseUrl()
             build.released = true;
             if (!build.save())
               flash.message = "Could not save the build"
      } else
               flash.message = releaseCommand.getError()
      redirect(action:show,id:build.id)
    }
    
}
